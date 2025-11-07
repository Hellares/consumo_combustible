import 'dart:async';
import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';


class DioConfig {
  static Dio? _dio;
  
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    // Log info del entorno
    ApiConfig.logEnvironmentInfo();

    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.headers,
      
      // Configuraciones optimizadas
      persistentConnection: true,
      followRedirects: false,
      maxRedirects: 0,
      // ✅ CRÍTICO: 401 debe ir a onError para que funcione el refresh automático
      validateStatus: (status) => status != null && status < 500 && status != 401,
    ));

    // Interceptores según entorno
    dio.interceptors.addAll([
      OptimizedAuthInterceptor(),
      
      // Retry con configuración por entorno
      SmartRetryInterceptor(),
      
      // Logs solo en desarrollo
      if (kDebugMode) LogInterceptor(
        requestBody: false,
        responseBody: false,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    ]);

    if (kDebugMode) {
      print('✅ Dio configurado para ${ApiConfig.isProduction ? "producción" : "desarrollo"}');
    }

    return dio;
  }

  static void resetInstance() {
    _dio?.close(force: true);
    _dio = null;
  }
}

// ✅ Interceptor de autenticación con REFRESH TOKEN AUTOMÁTICO
class OptimizedAuthInterceptor extends Interceptor {
  String? _cachedToken;
  DateTime? _tokenCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  bool _isRefreshing = false;
  final List<Function()> _retryQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isAuthEndpoint(options.path)) {
      final token = await _getTokenOptimized();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si es error 401 y no es un endpoint de auth, intentar refresh
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {

      if (kDebugMode) print('🔄 Token expirado, intentando renovar...');

      // Si ya hay un refresh en progreso, agregar la petición a la cola
      if (_isRefreshing) {
        if (kDebugMode) print('⏳ Ya hay un refresh en progreso, encolando petición...');

        // Agregar la petición a la cola para reintentarla cuando el refresh termine
        final completer = Completer<Response>();
        _retryQueue.add(() async {
          try {
            final newToken = await _getTokenOptimized();
            if (newToken != null) {
              err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            }
            final retryResponse = await DioConfig.instance.fetch(err.requestOptions);
            completer.complete(retryResponse);
          } catch (e) {
            completer.completeError(err);
          }
        });

        // Esperar a que el refresh termine y se reintente la petición
        try {
          final retryResponse = await completer.future;
          if (kDebugMode) print('✅ Petición encolada reintentada exitosamente');
          handler.resolve(retryResponse);
          return;
        } catch (e) {
          if (kDebugMode) print('❌ Petición encolada falló después del refresh');
          handler.next(err);
          return;
        }
      }

      _isRefreshing = true;
      
      try {
        final fastStorage = GetIt.instance<FastStorageService>();
        final refreshToken = await fastStorage.read('refresh_token');
        
        if (refreshToken == null || refreshToken.isEmpty) {
          if (kDebugMode) print('❌ No hay refresh token disponible');
          _clearTokenCache();
          _isRefreshing = false;
          handler.next(err);
          return;
        }
        
        // ✅ Crear un Dio temporal SIN interceptores para evitar loops
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: Duration(seconds: 10),
          receiveTimeout: Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ));
        
        if (kDebugMode) print('📡 Llamando a /api/auth/refresh...');
        
        final response = await refreshDio.post(
          '/api/auth/refresh',
          data: {'refreshToken': refreshToken},
        );
        
        if (kDebugMode) {
          print('📡 Refresh response status: ${response.statusCode}');
          print('📡 Refresh response data type: ${response.data.runtimeType}');
          print('📡 Refresh response data: ${response.data}');
        }
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Verificar que response.data no sea null
          if (response.data == null) {
            if (kDebugMode) print('❌ Response data es null');
            _clearTokenCache();
            _isRefreshing = false;
            handler.next(err);
            return;
          }
          
          final authResponse = AuthResponse.fromJson(response.data);
          
          // Guardar nuevos tokens
          final newAccessToken = authResponse.data?.accessToken;
          final newRefreshToken = authResponse.data?.refreshToken;
          
          if (newAccessToken != null && newRefreshToken != null) {
            await fastStorage.write('access_token', newAccessToken);
            await fastStorage.write('refresh_token', newRefreshToken);
            await fastStorage.write('token', newAccessToken); // Compatibilidad
            
            // Actualizar user data completo
            final userData = await fastStorage.read('user');
            if (userData != null && userData is Map<String, dynamic>) {
              final updatedUserData = Map<String, dynamic>.from(userData);
              if (updatedUserData['data'] != null) {
                updatedUserData['data'] = Map<String, dynamic>.from(updatedUserData['data']);
                updatedUserData['data']['accessToken'] = newAccessToken;
                updatedUserData['data']['refreshToken'] = newRefreshToken;
                await fastStorage.write('user', updatedUserData);
              }
            }
            
            _clearTokenCache();
            
            if (kDebugMode) print('✅ Tokens renovados exitosamente');
            
            // Reintentar la petición original con el nuevo token
            err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            try {
              final retryResponse = await DioConfig.instance.fetch(err.requestOptions);
              if (kDebugMode) print('✅ Petición reintentada exitosamente');

              // Procesar la cola de peticiones pendientes
              _processRetryQueue();

              _isRefreshing = false;
              handler.resolve(retryResponse);
              return;
            } catch (retryError) {
              if (kDebugMode) print('❌ Error al reintentar petición: $retryError');
              _isRefreshing = false;
              handler.next(err);
              return;
            }
          }
        } else {
          // Refresh token inválido o expirado
          if (kDebugMode) {
            print('❌ Refresh token inválido o expirado (status: ${response.statusCode})');
            print('   Response: ${response.data}');
          }
          _clearTokenCache();
          _isRefreshing = false;

          // Limpiar tokens del almacenamiento
          try {
            final fastStorage = GetIt.instance<FastStorageService>();
            await fastStorage.delete('access_token');
            await fastStorage.delete('refresh_token');
            await fastStorage.delete('token');
            await fastStorage.delete('user');
            if (kDebugMode) print('🧹 Tokens limpiados - usuario debe hacer login nuevamente');
          } catch (e) {
            if (kDebugMode) print('⚠️ Error limpiando tokens: $e');
          }

          handler.next(err);
        }

      } catch (e) {
        if (kDebugMode) print('❌ Error en refresh token: $e');
        _clearTokenCache();
        _isRefreshing = false;
        handler.next(err);
      }
    } else {
      // Error que no es 401 o es endpoint de auth
      if (err.response?.statusCode == 401) {
        _clearTokenCache();
      }
      handler.next(err);
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/login') ||
           path.contains('/register') ||
           path.contains('/auth/login') ||
           path.contains('/auth/register') ||
           path.contains('/auth/refresh');
  }

  // ✅ SÚPER OPTIMIZADO: Extraer access token del almacenamiento
  Future<String?> _getTokenOptimized() async {
    // 1. Cache del token en memoria - súper rápido
    if (_cachedToken != null &&
        _tokenCacheTime != null &&
        DateTime.now().difference(_tokenCacheTime!) < _cacheValidDuration) {
      return _cachedToken;
    }
    
    try {
      // 2. Usar FastStorageService que ya tiene cache en memoria
      final fastStorage = GetIt.instance<FastStorageService>();
      
      // Primero intentar con access_token
      final accessToken = await fastStorage.read('access_token');
      if (accessToken != null && accessToken is String && accessToken.isNotEmpty) {
        _cachedToken = accessToken;
        _tokenCacheTime = DateTime.now();
        return _cachedToken;
      }
      
      // Compatibilidad: intentar con 'token'
      final token = await fastStorage.read('token');
      if (token != null && token is String && token.isNotEmpty) {
        _cachedToken = token;
        _tokenCacheTime = DateTime.now();
        return _cachedToken;
      }
      
      // Si no está, extraer del objeto user
      final userData = await fastStorage.read('user');
      if (userData != null) {
        final authResponse = AuthResponse.fromJson(userData);
        final userToken = authResponse.data?.accessToken;
        
        if (userToken != null && userToken.isNotEmpty) {
          _cachedToken = userToken;
          _tokenCacheTime = DateTime.now();
          return _cachedToken;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error obteniendo token: $e');
      }
    }
    
    return null;
  }

  void _clearTokenCache() {
    _cachedToken = null;
    _tokenCacheTime = null;
  }

  void forceTokenRefresh() {
    _clearTokenCache();
  }

  // Procesar la cola de peticiones que esperaban el refresh
  void _processRetryQueue() {
    if (_retryQueue.isEmpty) return;

    if (kDebugMode) print('🔄 Procesando ${_retryQueue.length} peticiones en cola...');

    // Ejecutar todas las peticiones en cola
    for (final retryFunction in _retryQueue) {
      retryFunction.call();
    }

    // Limpiar la cola
    _retryQueue.clear();
  }
}

// Interceptor de retry inteligente usando configuración de ApiConfig
class SmartRetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final retryCount = (err.requestOptions.extra['retryCount'] ?? 0) as int;
    
    if (_shouldRetry(err) && retryCount < ApiConfig.maxRetries) {
      final newRetryCount = retryCount + 1;
      err.requestOptions.extra['retryCount'] = newRetryCount;
      
      if (kDebugMode) {
        print('🔄 Retry $newRetryCount/${ApiConfig.maxRetries} para ${err.requestOptions.path}');
      }
      
      await Future.delayed(ApiConfig.retryDelay);
      
      try {
        final response = await DioConfig.instance.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
            sendTimeout: err.requestOptions.sendTimeout,
            receiveTimeout: err.requestOptions.receiveTimeout,
          ),
        );
        
        if (kDebugMode) print('✅ Retry exitoso');
        handler.resolve(response);
        return;
      } catch (retryError) {
        if (kDebugMode) print('❌ Retry $newRetryCount falló');
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.response?.statusCode ?? 0) >= 500) &&
           !err.requestOptions.path.contains('/login') &&
           !err.requestOptions.path.contains('/register');
  }
}

// Configuraciones específicas para casos especiales
class DioConfigSpecial {
  // Para uploads de archivos grandes
  static Dio createUploadDio() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30), // Más tiempo para uploads
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: ApiConfig.headers,
    ));

    dio.interceptors.add(OptimizedAuthInterceptor());
    return dio;
  }

  // Para servicios externos (sin auth)
  static Dio createExternalDio(String baseUrl) {
    return Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ));
  }
}
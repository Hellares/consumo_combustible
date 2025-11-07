import 'dart:convert';
// import 'dart:isolate';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/data/api/dio_config.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';


class AuthService {
  final Dio _dio;

  AuthService() : _dio = DioConfig.instance;

  // LOGIN OPTIMIZADO PARA PRODUCCIÓN
  Future<Resource<AuthResponse>> login(String dni, String password) async {
    Stopwatch? totalStopwatch;
    if (kDebugMode) {
      totalStopwatch = Stopwatch()..start();
    }
    
    try {
      if (kDebugMode) print('🔐 AuthService: Iniciando login para DNI: $dni');
      
      // 1. PETICIÓN OPTIMIZADA con timeouts específicos para LOGIN
      Stopwatch? networkStopwatch;
      if (kDebugMode) {
        networkStopwatch = Stopwatch()..start();
      }
      
      final response = await _dio.post(
        '/api/auth/login',
        data: {'dni': dni, 'password': password},
        options: Options(
          // ✅ USAR TIMEOUTS ESPECÍFICOS PARA LOGIN (más largos)
          sendTimeout: ApiConfig.loginConnectTimeout,
          receiveTimeout: ApiConfig.loginReceiveTimeout,
          headers: {
            'X-Request-Type': 'login', // Identificar petición de login
          },
        ),
      );
      
      if (kDebugMode) {
        networkStopwatch?.stop();
        print('📡 Red: ${networkStopwatch?.elapsedMilliseconds}ms - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 2. PARSING OPTIMIZADO
        Stopwatch? parseStopwatch;
        if (kDebugMode) {
          parseStopwatch = Stopwatch()..start();
        }
        
        AuthResponse authResponse;
        
        // Si el JSON es muy grande (>50KB), usar isolate
        final jsonString = response.data is String 
            ? response.data as String 
            : jsonEncode(response.data);
            
        if (jsonString.length > 50000) {
          if (kDebugMode) print('📦 JSON grande (${jsonString.length} chars), usando isolate...');
          authResponse = await compute(_parseAuthResponseInIsolate, jsonString);
        } else {
          // Parsing directo (más rápido para JSONs pequeños)
          authResponse = AuthResponse.fromJson(response.data);
        }
        
        if (kDebugMode) {
          parseStopwatch?.stop();
          totalStopwatch?.stop();
          
          print('⚡ Parsing: ${parseStopwatch?.elapsedMilliseconds}ms');
          print('👤 Usuario: ${authResponse.data?.user?.nombres}');
          print('⏱️ Total AuthService: ${totalStopwatch?.elapsedMilliseconds}ms');
        }
        
        return Success(authResponse);
      } else {
        if (kDebugMode) {
          totalStopwatch?.stop();
          print('❌ Login falló en ${totalStopwatch?.elapsedMilliseconds}ms - Status: ${response.statusCode}');
        }
        return Error(_extractErrorMessage(response.data));
      }
      
    } on DioException catch (e) {
      if (kDebugMode) {
        totalStopwatch?.stop();
        print('💥 DioException en ${totalStopwatch?.elapsedMilliseconds}ms: ${e.type} - ${e.message}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        totalStopwatch?.stop();
        print('💥 Error inesperado en ${totalStopwatch?.elapsedMilliseconds}ms: $e');
      }
      return Error('Error inesperado: ${e.toString()}');
    }
  }

  // REFRESH TOKEN - Renovar tokens usando refresh token
  Future<Resource<AuthResponse>> refreshToken(String refreshToken) async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      print('🔄 AuthService: Renovando tokens...');
    }
    
    try {
      final response = await _dio.post(
        '/api/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (kDebugMode) {
        stopwatch?.stop();
        print('✅ Tokens renovados en ${stopwatch?.elapsedMilliseconds}ms - Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);
        return Success(authResponse);
      } else {
        if (kDebugMode) {
          print('❌ Refresh falló - Status: ${response.statusCode}');
        }
        return Error(_extractErrorMessage(response.data));
      }
      
    } on DioException catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('💥 Error refresh en ${stopwatch?.elapsedMilliseconds}ms: ${e.type} - ${e.message}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('💥 Error inesperado refresh en ${stopwatch?.elapsedMilliseconds}ms: $e');
      }
      return Error('Error inesperado: ${e.toString()}');
    }
  }

  // LOGOUT OPTIMIZADO - Envía refresh token al backend
  Future<Resource<bool>> logout(String? refreshToken) async {
  Stopwatch? stopwatch;
  if (kDebugMode) {
    stopwatch = Stopwatch()..start();
    print('🚪 AuthService: Iniciando logout...');
  }
  
  try {
    // ✅ Enviar refresh token al backend para revocarlo
    final response = await _dio.post(
      '/api/auth/logout',
      data: refreshToken != null ? {'refreshToken': refreshToken} : null,
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 8),
      ),
    );
    
    if (kDebugMode) {
      stopwatch?.stop();
      print('✅ Logout exitoso en ${stopwatch?.elapsedMilliseconds}ms - Status: ${response.statusCode}');
    }
    
    // ✅ VERIFICAR status code real
    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
      return Success(true);
    } else {
      if (kDebugMode) print('⚠️ Logout parcial - Status: ${response.statusCode}');
      return Success(true); // Aún así considerar exitoso para limpiar local
    }
    
  } on DioException catch (e) {
    if (kDebugMode) {
      stopwatch?.stop();
      print('💥 Error Dio logout en ${stopwatch?.elapsedMilliseconds}ms: ${e.type} - ${e.message}');
    }
    
    // ✅ DECISIÓN: ¿Fallar o continuar con logout local?
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      
      // Red no disponible - continuar con logout local
      if (kDebugMode) print('🔄 Red no disponible, continuando logout local...');
      return Success(true);
    } else {
      // Otros errores - reportar pero continuar logout local
      if (kDebugMode) print('⚠️ Error servidor, continuando logout local...');
      return Success(true);
    }
    
  } catch (e) {
    if (kDebugMode) {
      stopwatch?.stop();
      print('💥 Error inesperado logout en ${stopwatch?.elapsedMilliseconds}ms: $e');
    }
    
    // ✅ SIEMPRE continuar con logout local aunque falle el servidor
    return Success(true);
  }
}

  // LOGOUT ALL - Cerrar todas las sesiones del usuario
  Future<Resource<bool>> logoutAll() async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      print('🚪 AuthService: Cerrando todas las sesiones...');
    }
    
    try {
      final response = await _dio.post(
        '/api/auth/logout-all',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      
      if (kDebugMode) {
        stopwatch?.stop();
        print('✅ Logout-all exitoso en ${stopwatch?.elapsedMilliseconds}ms - Status: ${response.statusCode}');
      }
      
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return Success(true);
      } else {
        if (kDebugMode) print('⚠️ Logout-all parcial - Status: ${response.statusCode}');
        return Success(true); // Aún así considerar exitoso para limpiar local
      }
      
    } on DioException catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('💥 Error Dio logout-all en ${stopwatch?.elapsedMilliseconds}ms: ${e.type} - ${e.message}');
      }
      
      // Continuar con logout local aunque falle el servidor
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        if (kDebugMode) print('🔄 Red no disponible, continuando logout local...');
        return Success(true);
      } else {
        if (kDebugMode) print('⚠️ Error servidor, continuando logout local...');
        return Success(true);
      }
      
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('💥 Error inesperado logout-all en ${stopwatch?.elapsedMilliseconds}ms: $e');
      }
      return Success(true);
    }
  }

  // HELPER: Extraer mensajes de error optimizado
  String _extractErrorMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (data['message'] is List) {
          final messages = data['message'] as List;
          return messages.take(3).join(', '); // Limitar mensajes
        } else if (data['message'] is String) {
          return data['message'];
        } else if (data['error'] is String) {
          return data['error'];
        }
      }
      return 'Error en el servidor';
    } catch (e) {
      return 'Error procesando respuesta del servidor';
    }
  }

  // HELPER: Manejo de errores Dio optimizado
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Conexión lenta. Verifica tu internet.';
      
      case DioExceptionType.sendTimeout:
        return 'Envío lento. Intenta nuevamente.';
      
      case DioExceptionType.receiveTimeout:
        return 'Servidor lento. Intenta más tarde.';
      
      case DioExceptionType.connectionError:
        return 'Sin conexión. Verifica tu internet.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return _extractErrorMessage(error.response?.data);
          case 401:
            return 'DNI o contraseña incorrectos';
          case 403:
            return 'Acceso denegado';
          case 404:
            return 'Servicio no disponible';
          case 429:
            return 'Muchas peticiones. Espera un momento.';
          case 500:
          case 502:
          case 503:
          case 504:
            return 'Servidor no disponible. Intenta más tarde.';
          default:
            return 'Error del servidor ($statusCode)';
        }
      
      case DioExceptionType.cancel:
        return 'Operación cancelada';
      
      case DioExceptionType.unknown:
        final message = error.message ?? '';
        if (message.contains('SocketException')) {
          return 'Sin internet';
        }
        return 'Error de conexión';
      
      default:
        return 'Error inesperado';
    }
  }
}

// FUNCIÓN PARA PARSING EN ISOLATE
AuthResponse _parseAuthResponseInIsolate(String jsonString) {
  Stopwatch? stopwatch;
  if (kDebugMode) {
    stopwatch = Stopwatch()..start();
  }
  
  try {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final result = AuthResponse.fromJson(jsonMap);
    
    if (kDebugMode) {
      stopwatch?.stop();
      print('🔄 Parsing en isolate: ${stopwatch?.elapsedMilliseconds}ms');
    }
    
    return result;
  } catch (e) {
    if (kDebugMode) {
      stopwatch?.stop();
      print('❌ Error parsing en isolate (${stopwatch?.elapsedMilliseconds}ms): $e');
    }
    rethrow;
  }
}
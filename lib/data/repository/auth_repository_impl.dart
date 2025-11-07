import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/api/dio_config.dart';
import 'package:consumo_combustible/data/datasource/remote/service/auth_service.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final FastStorageService fastStorage;
  
  AuthRepositoryImpl(this.authService, this.fastStorage);

  @override
  Future<Resource<AuthResponse>> login(String dni, String password) {
    return authService.login(dni, password);
  }

  
  
  @override
  Future<AuthResponse?> getUserSession() async {
    try {
      final userData = await fastStorage.read('user');
      if (userData != null) {
        return AuthResponse.fromJson(userData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error obteniendo sesión de usuario: $e');
      return null;
    }
  }
  
  @override
  Future<void> saveUserSession(AuthResponse authResponse) async {
    try {
      // ✅ CRÍTICO: Guardar user data completo en SharedPreferences
      final userJson = authResponse.toJson();
      
      // Guardar usando FastStorage
      await fastStorage.write('user', userJson);
      
      // Guardar tokens por separado para acceso rápido
      final accessToken = authResponse.data?.accessToken;
      final refreshToken = authResponse.data?.refreshToken;
      
      if (accessToken != null && accessToken.isNotEmpty) {
        await fastStorage.write('access_token', accessToken);
      }
      
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await fastStorage.write('refresh_token', refreshToken);
      }
      
      // Mantener compatibilidad con código existente
      if (accessToken != null && accessToken.isNotEmpty) {
        await fastStorage.write('token', accessToken);
      }
      
      // Forzar actualización del token en el interceptor de Dio
      _forceAuthInterceptorRefresh();
      
      if (kDebugMode) {
        print('✅ Sesión guardada exitosamente');
        print('   - Access Token: ${accessToken?.substring(0, 20)}...');
        print('   - Refresh Token: ${refreshToken?.substring(0, 20)}...');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error guardando sesión: $e');
      rethrow;
    }
  }


  // ✅ MÉTODO: Para datos menos críticos que pueden guardarse async
 Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      // Para preferencias no críticas, usar writeAsync
      await fastStorage.writeAsync('user_preferences', preferences);
      if (kDebugMode) print('Preferencias guardadas en background');
    } catch (e) {
      if (kDebugMode) print('Error guardando preferencias: $e');
      // No relanzar error para preferencias no críticas
    }
  }

  // ✅ OPTIMIZACIÓN: Método para guardar configuraciones no críticas
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      await fastStorage.writeAsync('app_settings', settings);
      if (kDebugMode) print('Configuraciones guardadas en background');
    } catch (e) {
      if (kDebugMode) print('Error guardando configuraciones: $e');
    }
  }

  // ✅ DEBUG UTILITY: Ver stats del cache
  Map<String, dynamic> getCacheInfo() {
    if (!kDebugMode) return {};
    return fastStorage.getStats();
  }

  @override
  Future<bool> logout() async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      print('🚪 Iniciando logout...');
    }
    
    try {
      // Obtener refresh token antes de limpiar
      final refreshToken = await getRefreshToken();
      
      // Llamar al servicio de logout con el refresh token
      final result = await authService.logout(refreshToken);
      
      if (result is Success) {
        // Limpiar almacenamiento local
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        
        if (kDebugMode) {
          stopwatch?.stop();
          print('✅ Logout completado en ${stopwatch?.elapsedMilliseconds}ms');
        }
        return true;
      } else {
        // Aunque falle el servidor, limpiar local
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        
        if (kDebugMode) {
          stopwatch?.stop();
          print('⚠️ Logout local completado (servidor falló) en ${stopwatch?.elapsedMilliseconds}ms');
        }
        return true;
      }
      
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('❌ Error en logout (${stopwatch?.elapsedMilliseconds}ms): $e');
      }
      
      // Intentar limpiar local al menos
      try {
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        return true;
      } catch (localError) {
        if (kDebugMode) print('💥 Error crítico en logout: $localError');
        return false;
      }
    }
  }

  @override
  Future<bool> logoutAll() async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      print('🚪 Iniciando logout de todas las sesiones...');
    }
    
    try {
      // Llamar al servicio de logout-all
      final result = await authService.logoutAll();
      
      if (result is Success) {
        // Limpiar almacenamiento local
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        
        if (kDebugMode) {
          stopwatch?.stop();
          print('✅ Logout-all completado en ${stopwatch?.elapsedMilliseconds}ms');
        }
        return true;
      } else {
        // Aunque falle el servidor, limpiar local
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        
        if (kDebugMode) {
          stopwatch?.stop();
          print('⚠️ Logout-all local completado (servidor falló) en ${stopwatch?.elapsedMilliseconds}ms');
        }
        return true;
      }
      
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('❌ Error en logout-all (${stopwatch?.elapsedMilliseconds}ms): $e');
      }
      
      // Intentar limpiar local al menos
      try {
        await _clearLocalSession();
        _forceAuthInterceptorRefresh();
        return true;
      } catch (localError) {
        if (kDebugMode) print('💥 Error crítico en logout-all: $localError');
        return false;
      }
    }
  }

  @override
  Future<Resource<AuthResponse>> refreshToken(String refreshToken) async {
    try {
      if (kDebugMode) print('🔄 Renovando tokens...');

      final result = await authService.refreshToken(refreshToken);

      if (result is Success<AuthResponse>) {
        // Guardar los nuevos tokens
        await saveUserSession(result.data);

        if (kDebugMode) print('✅ Tokens renovados y guardados');
        return result;
      } else {
        if (kDebugMode) print('❌ Error renovando tokens');
        return result;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error en refreshToken: $e');
      return Error('Error renovando tokens: $e');
    }
  }

  // ✅ Método mejorado para refresh automático con validación
  Future<Resource<AuthResponse>> refreshTokenWithValidation() async {
    try {
      final storedRefreshToken = await getRefreshToken();

      if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
        return Error('No hay refresh token disponible');
      }

      final result = await refreshToken(storedRefreshToken);

      if (result is Success<AuthResponse>) {
        // Validar que los tokens sean válidos
        final newAccessToken = result.data.data?.accessToken;
        final newRefreshToken = result.data.data?.refreshToken;

        if (newAccessToken != null && newRefreshToken != null &&
            newAccessToken.isNotEmpty && newRefreshToken.isNotEmpty) {

          if (kDebugMode) print('✅ Refresh validado exitosamente');
          return result;
        } else {
          return Error('Tokens recibidos inválidos');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) print('❌ Error en refresh con validación: $e');
      return Error('Error renovando tokens: $e');
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      // Primero intentar desde cache directo del refresh token
      final refreshToken = await fastStorage.read('refresh_token');
      if (refreshToken != null && refreshToken is String && refreshToken.isNotEmpty) {
        return refreshToken;
      }
      
      // Si no está, extraer del objeto user
      final userData = await fastStorage.read('user');
      if (userData != null) {
        final authResponse = AuthResponse.fromJson(userData);
        return authResponse.data?.refreshToken;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo refresh token: $e');
      return null;
    }
  }

/// ✅ MÉTODO PRIVADO: Limpiar sesión local MEJORADO
Future<void> _clearLocalSession() async {
  try {
    if (kDebugMode) print('🧹 Limpiando almacenamiento local...');
    
    // Lista de keys a eliminar
    final keysToDelete = [
      'user',
      'token',
      'access_token',
      'refresh_token',
      'selected_role',
      'selected_location',
    ];
    
    // Eliminar cada key de forma secuencial para asegurar que se eliminen
    for (final key in keysToDelete) {
      try {
        await fastStorage.delete(key);
        if (kDebugMode) print('   ✓ $key: eliminado');
      } catch (e) {
        if (kDebugMode) print('   ✗ $key: error al eliminar - $e');
      }
    }

    // ✅ CRÍTICO: Limpiar cache en memoria para evitar datos obsoletos
    fastStorage.clearMemoryCache();
    
    // ✅ VERIFICACIÓN: Comprobar que los datos se eliminaron
    if (kDebugMode) {
      print('🔍 Verificando eliminación...');
      for (final key in keysToDelete) {
        final exists = await fastStorage.exists(key);
        if (exists) {
          print('   ⚠️ $key: AÚN EXISTE después de eliminar!');
        } else {
          print('   ✓ $key: confirmado eliminado');
        }
      }
      print('✅ Limpieza completada y verificada');
    }
    
  } catch (e) {
    if (kDebugMode) print('❌ Error limpiando sesión local: $e');
    rethrow;
  }
}

  // ✅ Método privado para limpiar cache del AuthInterceptor
  void _forceAuthInterceptorRefresh() {
    try {
      final authInterceptors = DioConfig.instance.interceptors
          .whereType<OptimizedAuthInterceptor>();
      
      if (authInterceptors.isNotEmpty) {
        authInterceptors.first.forceTokenRefresh();
        if (kDebugMode) print('Cache del AuthInterceptor limpiado');
      } else {
        if (kDebugMode) print('AuthInterceptor no encontrado');
      }
    } catch (e) {
      if (kDebugMode) print('Error limpiando cache del interceptor: $e');
      // No relanzar el error ya que no es crítico
    }
  }

  // ✅ Método de utilidad para obtener información de sesión usando FastStorage
  Future<Map<String, dynamic>?> getSessionInfo() async {
    if (!kDebugMode) return null;
    
    try {
      final userData = await fastStorage.read('user');
      if (userData != null) {
        final authResponse = AuthResponse.fromJson(userData);
        return {
          'user_name': authResponse.data?.user?.nombres,
          'user_dni': authResponse.data?.user?.dni,
          'token_exists': authResponse.data?.accessToken.isNotEmpty ?? false,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('Error obteniendo info de sesión: $e');
      return null;
    }
  }

  // ✅ MÉTODO ADICIONAL: Verificar si hay sesión válida sin obtener todos los datos
  Future<bool> hasValidSession() async {
    try {
      final userData = await fastStorage.read('user');
      return userData != null;
    } catch (e) {
      if (kDebugMode) print('Error verificando sesión válida: $e');
      return false;
    }
  }

  Future<String?> getUserToken() async {
    try {
      // Primero intentar desde cache directo del access token
      final accessToken = await fastStorage.read('access_token');
      if (accessToken != null && accessToken is String && accessToken.isNotEmpty) {
        return accessToken;
      }
      
      // Compatibilidad: intentar con 'token'
      final token = await fastStorage.read('token');
      if (token != null && token is String && token.isNotEmpty) {
        return token;
      }
      
      // Si no está, extraer del objeto user
      final userData = await fastStorage.read('user');
      if (userData != null) {
        final authResponse = AuthResponse.fromJson(userData);
        return authResponse.data?.accessToken;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo token: $e');
      return null;
    }
  }

  // ✅ MÉTODO ADICIONAL: Limpiar solo cache sin logout del servidor
  Future<void> clearLocalData() async {
    try {
      await fastStorage.clear();
      _forceAuthInterceptorRefresh();
      
      if (kDebugMode) print('Datos locales limpiados completamente');
    } catch (e) {
      if (kDebugMode) print('Error limpiando datos locales: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveSelectedRole(SelectedRole selectedRole) async {
    try {
      final roleJson = selectedRole.toJson();
      await fastStorage.write('selected_role', roleJson);
      
      if (kDebugMode) print('✅ Rol seleccionado guardado: ${selectedRole.role.rol.nombre}');
    } catch (e) {
      if (kDebugMode) print('❌ Error guardando rol seleccionado: $e');
      rethrow;
    }
  }

  @override
  Future<SelectedRole?> getSelectedRole() async {
    try {
      final roleData = await fastStorage.read('selected_role');
      if (roleData != null) {
        return SelectedRole.fromJson(roleData);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error obteniendo rol seleccionado: $e');
      return null;
    }
  }

  @override
  Future<void> clearSelectedRole() async {
    try {
      await fastStorage.delete('selected_role');
      if (kDebugMode) print('🗑️ Rol seleccionado eliminado');
    } catch (e) {
      if (kDebugMode) print('❌ Error eliminando rol seleccionado: $e');
    }
  }
}
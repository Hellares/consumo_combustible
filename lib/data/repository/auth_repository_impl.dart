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
      // El token dentro del objeto se extrae cuando se necesita
      final userJson = authResponse.toJson();
      
      // Guardar usando FastStorage que usará SharedPreferences para 'user'
      await fastStorage.write('user', userJson);
      
      // Opcionalmente guardar solo el token en SecureStorage para máxima seguridad
      final token = authResponse.data?.token;
      if (token != null && token.isNotEmpty) {
        await fastStorage.write('token', token);
      }
      
      // Forzar actualización del token en el interceptor de Dio
      _forceAuthInterceptorRefresh();
      
      if (kDebugMode) print('Sesión guardada exitosamente');
    } catch (e) {
      if (kDebugMode) print('Error guardando sesión: $e');
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

  // @override
  // Future<bool> logout() async {
  //   Stopwatch? totalStopwatch;
  //   if (kDebugMode) {
  //     totalStopwatch = Stopwatch()..start();
  //     print('Iniciando logout completo...');
  //   }
    
  //   try {
  //     // 1. PRIMERO: Notificar al servidor
  //     Stopwatch? serverStopwatch;
  //     if (kDebugMode) {
  //       serverStopwatch = Stopwatch()..start();
  //     }
      
  //     final serverLogoutResult = await authService.logout();
      
  //     if (kDebugMode) {
  //       serverStopwatch?.stop();
  //       if (serverLogoutResult is Error) {
  //         print('Error en logout del servidor (${serverStopwatch?.elapsedMilliseconds}ms): ${(serverLogoutResult as Error).message}');
  //       } else {
  //         print('Logout del servidor exitoso en ${serverStopwatch?.elapsedMilliseconds}ms');
  //       }
  //     }
      
  //     // 2. SEGUNDO: Limpiar almacenamiento local
  //     Stopwatch? localStopwatch;
  //     if (kDebugMode) {
  //       localStopwatch = Stopwatch()..start();
  //     }
      
  //     await _clearLocalSession();
      
  //     if (kDebugMode) {
  //       localStopwatch?.stop();
  //       print('Sesión local limpiada en ${localStopwatch?.elapsedMilliseconds}ms');
  //     }
      
  //     // 3. TERCERO: Limpiar cache del AuthInterceptor
  //     _forceAuthInterceptorRefresh();
      
  //     if (kDebugMode) {
  //       totalStopwatch?.stop();
  //       print('Logout completo exitoso en ${totalStopwatch?.elapsedMilliseconds}ms');
  //     }
      
  //     return true;
      
  //   } catch (e) {
  //     if (kDebugMode) {
  //       totalStopwatch?.stop();
  //       print('Error en logout (${totalStopwatch?.elapsedMilliseconds}ms): $e');
  //     }
      
  //     // Si falla, al menos intentar limpiar local
  //     try {
  //       await _clearLocalSession();
  //       _forceAuthInterceptorRefresh();
        
  //       if (kDebugMode) print('Logout local completado a pesar del error');
  //       return true;
  //     } catch (localError) {
  //       // Este error SÍ debe ser visible en producción para debugging
  //       print('Error crítico en logout: $localError');
  //       return false;
  //     }
  //   }
  // }

  // ✅ Método privado para limpiar sesión local usando FastStorage
//  Future<void> _clearLocalSession() async {
//     try {
//       // Limpiar tanto user como token
//       await Future.wait([
//         fastStorage.delete('user'),
//         fastStorage.delete('token'),
//       ]);
      
//       if (kDebugMode) print('Sesión local limpiada');
//     } catch (e) {
//       if (kDebugMode) print('Error limpiando sesión local: $e');
//       rethrow;
//     }
//   }

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
          'user_name': authResponse.data?.user.nombres,
          'user_dni': authResponse.data?.user.dni,
          // 'empresas_count': authResponse.data?.empresas.length ?? 0,
          // 'needs_empresa_selection': authResponse.data?.needsEmpresaSelection ?? false,
          'token_exists': authResponse.data?.token.isNotEmpty ?? false,
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
      // Primero intentar desde cache directo del token
      final token = await fastStorage.read('token');
      if (token != null && token is String && token.isNotEmpty) {
        return token;
      }
      
      // Si no está, extraer del objeto user
      final userData = await fastStorage.read('user');
      if (userData != null) {
        final authResponse = AuthResponse.fromJson(userData);
        return authResponse.data?.token;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('Error obteniendo token: $e');
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


//!revisar para implementar el logout completo (servidor + local + rol)
//   @override
//   Future<bool> logout() async {
//     // ... código existente de logout
    
//     try {
//       // Limpiar rol seleccionado además de sesión
//       await Future.wait([
//         _clearLocalSession(),
//         clearSelectedRole(), // 🆕 Agregar esto
//       ]);
      
//       _forceAuthInterceptorRefresh();
      
//       if (kDebugMode) print('✅ Logout completo (sesión + rol)');
//       return true;
//     } catch (e) {
//       // ... manejo de errores
//     }
//   }
// }

  
}
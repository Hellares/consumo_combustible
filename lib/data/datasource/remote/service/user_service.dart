
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<Resource<UserResponse>> getUsers({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      // El backend usa offset 0-indexed (Prisma skip)
      // Página 1: offset = 0, Página 2: offset = 10, etc.
      final offset = (page - 1) * pageSize;
      
      if (kDebugMode) {
        print('📋 [UserService] Obteniendo usuarios (page: $page, offset: $offset, limit: $pageSize)...');
      }
      
      final response = await _dio.get(
        '/api/user',
        queryParameters: {
          'offset': offset,
          'limit': pageSize,
        },
      );

      if (kDebugMode) {
        print('✅ Response usuarios: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final userResponse = UserResponse.fromJson(responseData);

          if (kDebugMode) {
            print('✅ ${userResponse.data.data.length} usuarios cargados');
          }

          return Success(userResponse);
        }

        return Error('Formato de respuesta inválido para usuarios');
      }

      return Error('Error ${response.statusCode} obteniendo usuarios');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getUsers: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('No se encontraron usuarios');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error de conexión: ${e.message}';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) print('❌ Error general en getUsers: $e');
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<UserResponse>> searchUsers(String query, {String searchType = 'nombre'}) async {
    try {
      if (kDebugMode) {
        print('📋 [UserService] Buscando usuarios por $searchType (query: $query)...');
      }

      final response = await _dio.get(
        '/api/user/search',
        queryParameters: {
          searchType: query,
        },
      );

      if (kDebugMode) {
        print('✅ Response usuarios: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final userResponse = UserResponse.fromJson(responseData);

          if (kDebugMode) {
            print('✅ ${userResponse.data.data.length} usuarios encontrados');
          }

          return Success(userResponse);
        }

        return Error('Formato de respuesta inválido para usuarios');
      }

      return Error('Error ${response.statusCode} obteniendo usuarios');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en searchUsers: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('No se encontraron usuarios');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error de conexión: ${e.message}';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) print('❌ Error general en searchUsers: $e');
      return Error('Error inesperado: $e');
    }
  }

  // Future<Resource<AuthResponse>> registerUser(
  //   RegisterUserRequest request,
  // ) async {
  //   try {
  //     if (kDebugMode) {
  //       print('📤 Registrando usuario: ${request.toJson()}');
  //     }

  //     final response = await _dio.post(
  //       '/api/auth',
  //       data: request.toJson(),
  //     );

  //     if (kDebugMode) {
  //       print('📥 Respuesta del servidor: ${response.statusCode}');
  //       print('📥 Data: ${response.data}');
  //     }

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final authResponse = AuthResponse.fromJson(response.data);
        
  //       if (kDebugMode) {
  //         print('✅ Usuario registrado exitosamente: ${authResponse.data?.user.nombres}');
  //       }
        
  //       return Success(authResponse);
  //     } else {
  //       final errorMessage = response.data['message'] ?? 'Error al registrar usuario';
  //       if (kDebugMode) print('❌ Error del servidor: $errorMessage');
  //       return Error(errorMessage);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('❌ Excepción en registerUser: $e');
      
  //     if (e is DioException) {
  //       // Manejo específico de errores de Dio
  //       if (e.response != null) {
  //         final statusCode = e.response?.statusCode;
  //         final responseData = e.response?.data;
          
  //         if (kDebugMode) {
  //           print('🔴 DioException - Status: $statusCode');
  //           print('🔴 Response data: $responseData');
  //         }
          
  //         // Intentar extraer mensaje del servidor
  //         if (responseData is Map<String, dynamic>) {
  //           final message = responseData['message'] as String?;
  //           if (message != null && message.isNotEmpty) {
  //             return Error(message);
  //           }
  //         }
          
  //         // Mensajes específicos por código de error
  //         switch (statusCode) {
  //           case 400:
  //             return Error('Datos inválidos. Verifica la información.');
  //           case 409:
  //             return Error('El usuario ya existe. DNI o email duplicado.');
  //           case 422:
  //             return Error('Error de validación. Revisa los campos.');
  //           case 500:
  //             return Error('Error del servidor. Intenta más tarde.');
  //           default:
  //             return Error('Error al registrar usuario (Código: $statusCode)');
  //         }
  //       } else if (e.type == DioExceptionType.connectionTimeout) {
  //         return Error('Tiempo de conexión agotado. Verifica tu internet.');
  //       } else if (e.type == DioExceptionType.receiveTimeout) {
  //         return Error('El servidor tardó demasiado en responder.');
  //       } else if (e.type == DioExceptionType.connectionError) {
  //         return Error('No se pudo conectar al servidor. Verifica tu internet.');
  //       }
  //     }
      
  //     return Error('Error inesperado: ${e.toString()}');
  //   }
  // }

  Future<Resource<AuthResponse>> registerUser(
  RegisterUserRequest request,
) async {
  try {
    if (kDebugMode) {
      print('📤 Registrando usuario: ${request.toJson()}');
    }

    final response = await _dio.post(
      '/api/auth',
      data: request.toJson(),
    );

    if (kDebugMode) {
      print('📥 Respuesta del servidor: ${response.statusCode}');
      print('📥 Data: ${response.data}');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      
      // ⭐ NUEVO: Parsing manual para el registro (estructura aplanada)
      if (responseData['success'] == true && responseData['data'] != null) {
        final dataJson = Map<String, dynamic>.from(responseData['data'] as Map<String, dynamic>);
        
        // Extraer el token del data aplanado
        final token = dataJson.remove('token') as String?;
        
        // El resto de dataJson ahora es puro para el User (incluyendo roles)
        final user = User.fromJson(dataJson);
        
        // Construir AuthResponse manualmente para que encaje en la estructura existente
        final authResponse = AuthResponse(
          success: true,
          message: responseData['message'] ?? 'Usuario registrado exitosamente',
          data: Data(
            user: user,
            token: token ?? '', // Si no hay token, cadena vacía (ajusta si es necesario)
          ),
        );
        
        if (kDebugMode) {
          print('✅ Usuario registrado exitosamente: ${authResponse.data?.user.nombres}');
        }
        
        return Success(authResponse);
      } else {
        return Error(responseData['message'] ?? 'Error al registrar usuario');
      }
    } else {
      final errorMessage = response.data['message'] ?? 'Error al registrar usuario';
      if (kDebugMode) print('❌ Error del servidor: $errorMessage');
      return Error(errorMessage);
    }
  } catch (e) {
    if (kDebugMode) print('❌ Excepción en registerUser: $e');
    
    if (e is DioException) {
      // Manejo específico de errores de Dio (mantiene tu código existente)
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (kDebugMode) {
          print('🔴 DioException - Status: $statusCode');
          print('🔴 Response data: $responseData');
        }
        
        // Intentar extraer mensaje del servidor
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          if (message != null && message.isNotEmpty) {
            return Error(message);
          }
        }
        
        // Mensajes específicos por código de error (tu código existente)
        switch (statusCode) {
          case 400:
            return Error('Datos inválidos. Verifica la información.');
          case 409:
            return Error('El usuario ya existe. DNI o email duplicado.');
          case 422:
            return Error('Error de validación. Revisa los campos.');
          case 500:
            return Error('Error del servidor. Intenta más tarde.');
          default:
            return Error('Error al registrar usuario (Código: $statusCode)');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado. Verifica tu internet.');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('El servidor tardó demasiado en responder.');
      } else if (e.type == DioExceptionType.connectionError) {
        return Error('No se pudo conectar al servidor. Verifica tu internet.');
      }
    }
    
    return Error('Error inesperado: ${e.toString()}');
  }
}
}

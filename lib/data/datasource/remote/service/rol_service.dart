// lib/data/datasource/remote/service/rol_service.dart

import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RolService {
  final Dio dio;
  final FastStorageService storage;

  RolService(this.dio, this.storage);

  /// GET /api/roles - Obtiene todos los roles
  Future<Resource<RolesResponse>> getRoles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 [RolService] Obteniendo roles - page: $page, pageSize: $limit');
      }

      final token = await storage.read('token');
      
      final response = await dio.get(
        '/api/roles',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Roles obtenidos: ${response.data}');
      }

      // Si la API devuelve { success, message, data }
      if (response.data['success'] == true) {
        final rolesResponse = RolesResponse.fromJson(response.data['data']);
        return Success(rolesResponse);
      } else {
        return Error(response.data['message'] ?? 'Error al obtener roles');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
        print('Response: ${e.response?.data}');
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al obtener roles';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// GET /api/roles/:id - Obtiene un rol por ID
  Future<Resource<Rol>> getRolById(int rolId) async {
    try {
      if (kDebugMode) {
        print('🔍 [RolService] Obteniendo rol por ID: $rolId');
      }

      final token = await storage.read('token');
      
      final response = await dio.get(
        '/roles/$rolId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Rol obtenido: ${response.data}');
      }

      if (response.data['success'] == true) {
        final rol = Rol.fromJson(response.data['data']);
        return Success(rol);
      } else {
        return Error(response.data['message'] ?? 'Error al obtener el rol');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al obtener el rol';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// POST /api/roles - Crea un nuevo rol
  Future<Resource<Rol>> createRol(CreateRolRequest request) async {
    try {
      if (kDebugMode) {
        print('📝 [RolService] Creando rol: ${request.toJson()}');
      }

      final token = await storage.read('token');
      
      final response = await dio.post(
        '/api/roles',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Rol creado: ${response.data}');
      }

      if (response.data['success'] == true) {
        final rol = Rol.fromJson(response.data['data']);
        return Success(rol);
      } else {
        return Error(response.data['message'] ?? 'Error al crear el rol');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
        print('Response: ${e.response?.data}');
      }

      // Manejo de errores de validación
      if (e.response?.statusCode == 400) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors is List && errors.isNotEmpty) {
          return Error(errors.first['message'] ?? 'Error de validación');
        }
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al crear el rol';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// PUT /api/roles/:id - Actualiza un rol existente
  Future<Resource<Rol>> updateRol(
    int rolId,
    CreateRolRequest request,
  ) async {
    try {
      if (kDebugMode) {
        print('📝 [RolService] Actualizando rol $rolId: ${request.toJson()}');
      }

      final token = await storage.read('token');
      
      final response = await dio.put(
        '/api/roles/$rolId',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Rol actualizado: ${response.data}');
      }

      if (response.data['success'] == true) {
        final rol = Rol.fromJson(response.data['data']);
        return Success(rol);
      } else {
        return Error(response.data['message'] ?? 'Error al actualizar el rol');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al actualizar el rol';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// DELETE /api/roles/:id - Elimina (desactiva) un rol
  Future<Resource<void>> deleteRol(int rolId) async {
    try {
      if (kDebugMode) {
        print('🗑️ [RolService] Eliminando rol: $rolId');
      }

      final token = await storage.read('token');
      
      final response = await dio.delete(
        '/roles/$rolId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Rol eliminado: ${response.data}');
      }

      if (response.data['success'] == true) {
        return Success(null);
      } else {
        return Error(response.data['message'] ?? 'Error al eliminar el rol');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al eliminar el rol';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// PATCH /api/roles/:id/activar - Activa un rol
  Future<Resource<Rol>> activarRol(int rolId) async {
    try {
      if (kDebugMode) {
        print('✅ [RolService] Activando rol: $rolId');
      }

      final token = await storage.read('token');
      
      final response = await dio.patch(
        '/api/roles/$rolId/activar',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (kDebugMode) {
        print('✅ [RolService] Rol activado: ${response.data}');
      }

      if (response.data['success'] == true) {
        final rol = Rol.fromJson(response.data['data']);
        return Success(rol);
      } else {
        return Error(response.data['message'] ?? 'Error al activar el rol');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] DioException: ${e.message}');
      }

      final errorMessage = e.response?.data['message'] ?? 
                          e.response?.data['error'] ?? 
                          'Error de conexión al activar el rol';
      return Error(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolService] Exception: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
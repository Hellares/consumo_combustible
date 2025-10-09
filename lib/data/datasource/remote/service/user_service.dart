
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
}

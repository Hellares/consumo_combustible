// lib/data/datasource/remote/service/licencia_service.dart

import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LicenciaService {
  final Dio _dio;

  LicenciaService(this._dio);

  /// GET - Obtener todas las licencias con paginación
  Future<Resource<LicenciasResponse>> getLicencias({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('📋 [LicenciaService] Obteniendo licencias (page: $page, size: $pageSize)...');
      }

      final response = await _dio.get(
        '/api/licencias-conducir',
        queryParameters: {
          'page': page,
          'limit': pageSize,
        },
      );

      if (kDebugMode) {
        print('✅ Response licencias: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final licenciasResponse = LicenciasResponse.fromJson(responseData);

          if (kDebugMode) {
            print('✅ ${licenciasResponse.data.length} licencias cargadas');
          }

          return Success(licenciasResponse);
        }

        return Error('Formato de respuesta inválido para licencias');
      }

      return Error('Error ${response.statusCode} obteniendo licencias');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getLicencias: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('No se encontraron licencias');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error de conexión: ${e.message}';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) print('❌ Error general en getLicencias: $e');
      return Error('Error inesperado: $e');
    }
  }

  /// GET - Obtener licencia por ID
  Future<Resource<LicenciaConducir>> getLicenciaById(int licenciaId) async {
    try {
      if (kDebugMode) {
        print('🔍 [LicenciaService] Obteniendo licencia con ID: $licenciaId');
      }

      final response = await _dio.get('/api/licencias-conducir/$licenciaId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final licencia = LicenciaConducir.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Licencia ${licencia.numeroLicencia} obtenida');
          }

          return Success(licencia);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al obtener licencia';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// GET - Obtener licencias por usuario
  Future<Resource<List<LicenciaConducir>>> getLicenciasByUsuario(int usuarioId) async {
    try {
      if (kDebugMode) {
        print('👤 [LicenciaService] Obteniendo licencias del usuario: $usuarioId');
      }

      final response = await _dio.get('/api/licencias-conducir/usuario/$usuarioId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final licencias = (responseData['data'] as List)
              .map((e) => LicenciaConducir.fromJson(e))
              .toList();

          if (kDebugMode) {
            print('✅ ${licencias.length} licencias encontradas para usuario $usuarioId');
          }

          return Success(licencias);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al obtener licencias del usuario';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// GET - Obtener licencias vencidas
  Future<Resource<List<LicenciaConducir>>> getLicenciasVencidas() async {
    try {
      if (kDebugMode) {
        print('⚠️ [LicenciaService] Obteniendo licencias vencidas...');
      }

      final response = await _dio.get('/api/licencias-conducir/vencidas');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final licencias = (responseData['data'] as List)
              .map((e) => LicenciaConducir.fromJson(e))
              .toList();

          if (kDebugMode) {
            print('✅ ${licencias.length} licencias vencidas encontradas');
          }

          return Success(licencias);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al obtener licencias vencidas';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// GET - Obtener licencias próximas a vencer
  Future<Resource<List<LicenciaConducir>>> getLicenciasProximasVencer() async {
    try {
      if (kDebugMode) {
        print('🔔 [LicenciaService] Obteniendo licencias próximas a vencer...');
      }

      final response = await _dio.get('/api/licencias-conducir/proximas-vencer/30');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final licencias = (responseData['data'] as List)
              .map((e) => LicenciaConducir.fromJson(e))
              .toList();

          if (kDebugMode) {
            print('✅ ${licencias.length} licencias próximas a vencer encontradas');
          }

          return Success(licencias);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al obtener licencias próximas a vencer';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
import 'package:consumo_combustible/domain/models/create_unidad_request.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class UnidadService {
  final Dio _dio;

  UnidadService(this._dio);

  /// Obtiene las unidades de una zona específica
  Future<Resource<List<Unidad>>> getUnidadesByZona(int zonaId) async {
    try {
      if (kDebugMode) {
        print('🚗 Obteniendo unidades de la zona: $zonaId');
      }

      final response = await _dio.get('/api/unidades/zona/$zonaId');

      if (kDebugMode) {
        print('✅ Response unidades: ${response.statusCode}');
        // print('📦 Data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final unidadesResponse = UnidadesResponse.fromJson(
            responseData['data'],
          );

          if (kDebugMode) {
            print('✅ Unidades obtenidas: ${unidadesResponse.data.length}');
            for (var unidad in unidadesResponse.data) {
              print('   - ${unidad.placa} (${unidad.marca} ${unidad.modelo})');
            }
          }

          return Success(unidadesResponse.data);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo unidades');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getUnidadesByZona: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.response?.statusCode == 404) {
        return Error('No se encontraron unidades para esta zona');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en getUnidadesByZona: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtiene todas las unidades (con paginación opcional)
  // Future<Resource<List<Unidad>>> getAllUnidades({
  //   int page = 1,
  //   int pageSize = 100,
  // }) async {
  //   try {
  //     if (kDebugMode) {
  //       print('🚗 Obteniendo todas las unidades (página: $page)');
  //     }

  //     final response = await _dio.get(
  //       '/api/unidades',
  //       queryParameters: {
  //         'page': page,
  //         'pageSize': pageSize,
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = response.data;

  //       if (responseData['success'] == true && responseData['data'] != null) {
  //         final unidadesResponse = UnidadesResponse.fromJson(
  //           responseData['data'],
  //         );

  //         return Success(unidadesResponse.data);
  //       }

  //       return Error('Formato de respuesta inválido');
  //     }

  //     return Error('Error ${response.statusCode} obteniendo unidades');

  //   } on DioException catch (e) {
  //     if (kDebugMode) {
  //       print('❌ DioException en getAllUnidades: ${e.message}');
  //     }
  //     return Error('Error de conexión: ${e.message}');

  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('❌ Error general en getAllUnidades: $e');
  //     }
  //     return Error('Error inesperado: $e');
  //   }
  // }

  Future<Resource<Unidad>> createUnidad(CreateUnidadRequest request) async {
    try {
      if (kDebugMode) {
        print('🚗 Creando nueva unidad: ${request.placa}');
        print('📦 Request: ${request.toJson()}');
      }

      final response = await _dio.post(
        '/api/unidades',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('✅ Response status: ${response.statusCode}');
        print('📦 Response data: Data recibida de creacion de Unidad');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final unidad = Unidad.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Unidad creada exitosamente: ${unidad.placa} (ID: ${unidad.id})');
          }

          return Success(unidad);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.data['message']} al crear unidad');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en createUnidad: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      // Manejo de errores específicos del backend
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data['message'] ?? 'Datos inválidos';
        return Error('Error de validación: $errorMessage');
      } else if (e.response?.statusCode == 409) {
        return Error('La placa ya está registrada');
      } else if (e.response?.statusCode == 404) {
        return Error('Conductor u operador no encontrado');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en createUnidad: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<UnidadesResponse>> getAllUnidades({
    int page = 1,
    int pageSize  = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('🚗 Obteniendo todas las unidades (página: $page, tamaño: $pageSize)');
      }

      final response = await _dio.get(
        '/api/unidades',
        queryParameters: {
          'page': page,
          'limit': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          // Retornar el objeto completo UnidadesResponse con data y meta
          final unidadesResponse = UnidadesResponse.fromJson(
            responseData['data'],
          );

          if (kDebugMode) {
            print('✅ Unidades obtenidas: ${unidadesResponse.data.length}');
            print('📊 Total: ${unidadesResponse.meta.total}');
            print('📄 Página: ${unidadesResponse.meta.page}/${unidadesResponse.meta.totalPages}');
          }

          return Success(unidadesResponse);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo unidades');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getAllUnidades: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error general en getAllUnidades: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtiene una unidad por ID
  Future<Resource<Unidad>> getUnidadById(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🚗 Obteniendo unidad: $unidadId');
      }

      final response = await _dio.get('/api/unidades/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final unidad = Unidad.fromJson(responseData['data']);
          return Success(unidad);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo unidad');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getUnidadById: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return Error('Unidad no encontrada');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error general en getUnidadById: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<double?>> getUltimoKilometraje(int unidadId) async {
  try {
    if (kDebugMode) {
      print('🔍 Obteniendo último kilometraje de unidad: $unidadId');
    }

    final response = await _dio.get('/api/unidades/$unidadId/ultimo-kilometraje');

    if (kDebugMode) {
      print('✅ Response último km: ${response.statusCode}');
      print('📦 Data: ${response.data}');
    }

    if (response.statusCode == 200) {
      final responseData = response.data;

      if (responseData['success'] == true) {
        final ultimoKm = responseData['data']?['ultimoKilometraje'];
        return Success(ultimoKm?.toDouble());
      }

      return Error('Formato de respuesta inválido');
    }

    return Error('Error ${response.statusCode} obteniendo kilometraje');

  } on DioException catch (e) {
    if (kDebugMode) {
      print('❌ DioException en getUltimoKilometraje: ${e.message}');
    }

    if (e.response?.statusCode == 404) {
      // No hay registros previos
      return Success(null);
    }

    return Error('Error de conexión: ${e.message}');

  } catch (e) {
    if (kDebugMode) {
      print('❌ Error general: $e');
    }
    return Error('Error inesperado: $e');
  }
}
}
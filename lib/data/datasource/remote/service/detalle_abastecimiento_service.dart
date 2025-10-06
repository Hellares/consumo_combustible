import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DetalleAbastecimientoService {
  final Dio _dio;

  DetalleAbastecimientoService(this._dio);

  /// Obtener detalles de abastecimiento por grifo
  Future<Resource<Map<String, dynamic>>> getDetallesByGrifo({
    required int grifoId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      if (kDebugMode) {
        print('📡 [DetalleAbastecimientoService] Obteniendo detalles del grifo: $grifoId (página: $page)');
      }

      final response = await _dio.get(
        '/api/detalles-abastecimiento/',
        queryParameters: {
          'grifoId': grifoId,
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          
          // Parsear lista de detalles
          final List<DetalleAbastecimiento> detalles = (data['data'] as List)
              .map((item) => DetalleAbastecimiento.fromJson(item))
              .toList();

          // Parsear metadata
          final meta = DetalleAbastecimientoMeta.fromJson(data['meta']);

          if (kDebugMode) {
            print('✅ [DetalleAbastecimientoService] ${detalles.length} detalles obtenidos (Total: ${meta.total})');
          }

          return Success({
            'detalles': detalles,
            'meta': meta,
          });
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] DioException: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al obtener detalles';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Actualizar detalle de abastecimiento
  Future<Resource<DetalleAbastecimiento>> actualizarDetalle({
    required int detalleId,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (kDebugMode) {
        print('📝 [DetalleAbastecimientoService] Actualizando detalle: $detalleId');
      }

      final response = await _dio.patch(
        '/api/detalles-abastecimiento/$detalleId',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final detalle = DetalleAbastecimiento.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [DetalleAbastecimientoService] Detalle actualizado');
          }

          return Success(detalle);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al actualizar detalle';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Concluir detalle de abastecimiento
  Future<Resource<DetalleAbastecimiento>> concluirDetalle({
    required int detalleId,
    required int concluidoPorId,
  }) async {
    try {
      if (kDebugMode) {
        print('✅ [DetalleAbastecimientoService] Concluyendo detalle: $detalleId');
      }

      final response = await _dio.patch(
        '/api/detalles-abastecimiento/$detalleId/estado',
        data: {'estado': 'CONCLUIDO'},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final detalle = DetalleAbastecimiento.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [DetalleAbastecimientoService] Detalle concluido');
          }

          return Success(detalle);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al concluir detalle';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoService] Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
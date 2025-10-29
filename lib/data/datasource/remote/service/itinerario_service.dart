// lib/data/datasource/remote/service/itinerario_service.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ItinerarioService {
  final Dio _dio;

  ItinerarioService(this._dio);

  /// Obtener todos los itinerarios activos
  Future<Resource<List<Itinerario>>> getItinerariosActivos() async {
    try {
      if (kDebugMode) {
        print('🗺️ Obteniendo itinerarios activos...');
      }

      final response = await _dio.get(
        '/api/itinerarios',
        queryParameters: {
          'estado': 'ACTIVO',
        },
      );

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data']['data'] as List;
          final itinerarios = data.map((json) => Itinerario.fromJson(json)).toList();

          if (kDebugMode) {
            print('✅ Itinerarios cargados: ${itinerarios.length}');
            for (var it in itinerarios) {
              print('   - ${it.nombre} (${it.codigo})');
            }
          }

          return Success(itinerarios);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo itinerarios');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<Itinerario>> getItinerarioById(int id) async {
    try {
      if (kDebugMode) {
        print('🗺️ Obteniendo itinerario ID: $id...');
      }

      final response = await _dio.get('/api/itinerarios/$id');

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final itinerario = Itinerario.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Itinerario obtenido: ${itinerario.nombre}');
            print('   Código: ${itinerario.codigo}');
            print('   Tramos: ${itinerario.tramos?.length}');
            for (var tramo in itinerario.tramos ?? []) {
              print('      ${tramo.orden}. ${tramo.ciudadOrigen} → ${tramo.ciudadDestino}');
            }
          }

          return Success(itinerario);
        }

        return Error('Formato de respuesta inválido');
      }

      if (response.statusCode == 404) {
        return Error('Itinerario no encontrado');
      }

      return Error('Error ${response.statusCode} obteniendo itinerario');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      // Manejo especial para 404
      if (e.response?.statusCode == 404) {
        return Error('Itinerario no encontrado');
      }

      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// 🔥 NUEVO: Obtener itinerario por código
  Future<Resource<Itinerario>> getItinerarioByCodigo(String codigo) async {
    try {
      if (kDebugMode) {
        print('🗺️ Obteniendo itinerario código: $codigo...');
      }

      final response = await _dio.get('/api/itinerarios/codigo/$codigo');

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final itinerario = Itinerario.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Itinerario obtenido: ${itinerario.nombre}');
            print('   Tramos: ${itinerario.tramos?.length}');
          }

          return Success(itinerario);
        }

        return Error('Formato de respuesta inválido');
      }

      if (response.statusCode == 404) {
        return Error('Itinerario con código $codigo no encontrado');
      }

      return Error('Error ${response.statusCode} obteniendo itinerario');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return Error('Itinerario con código $codigo no encontrado');
      }

      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
  
}
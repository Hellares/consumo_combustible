// lib/data/datasource/remote/service/ruta_service.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class RutaService {
  final Dio _dio;

  RutaService(this._dio);

  /// Obtener todas las rutas activas
  Future<Resource<List<Ruta>>> getRutasActivas() async {
    try {
      if (kDebugMode) {
        print('🛣️ Obteniendo rutas activas...');
      }

      final response = await _dio.get(
        '/api/rutas',
        queryParameters: {
          'estado': 'ACTIVA',
        },
      );

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data']['data'] as List;
          final rutas = data.map((json) => Ruta.fromJson(json)).toList();

          if (kDebugMode) {
            print('✅ Rutas cargadas: ${rutas.length}');
            for (var ruta in rutas) {
              print('   - ${ruta.nombre} (${ruta.trayecto})');
            }
          }

          return Success(rutas);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo rutas');

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

  /// 🔥 NUEVO: Obtener ruta por ID
  Future<Resource<Ruta>> getRutaById(int id) async {
    try {
      if (kDebugMode) {
        print('🛣️ Obteniendo ruta ID: $id...');
      }

      final response = await _dio.get('/api/rutas/$id');

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ruta = Ruta.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Ruta obtenida: ${ruta.nombre}');
            print('   Código: ${ruta.codigo}');
            print('   Trayecto: ${ruta.trayecto}');
            print('   Distancia: ${ruta.distanciaKm} km');
            }

          return Success(ruta);
        }

        return Error('Formato de respuesta inválido');
      }

      if (response.statusCode == 404) {
        return Error('Ruta no encontrada');
      }

      return Error('Error ${response.statusCode} obteniendo ruta');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return Error('Ruta no encontrada');
      }

      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// 🔥 NUEVO: Obtener ruta por código
  Future<Resource<Ruta>> getRutaByCodigo(String codigo) async {
    try {
      if (kDebugMode) {
        print('🛣️ Obteniendo ruta código: $codigo...');
      }

      final response = await _dio.get('/api/rutas/codigo/$codigo');

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ruta = Ruta.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Ruta obtenida: ${ruta.nombre}');
          }

          return Success(ruta);
        }

        return Error('Formato de respuesta inválido');
      }

      if (response.statusCode == 404) {
        return Error('Ruta con código $codigo no encontrada');
      }

      return Error('Error ${response.statusCode} obteniendo ruta');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return Error('Ruta con código $codigo no encontrada');
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
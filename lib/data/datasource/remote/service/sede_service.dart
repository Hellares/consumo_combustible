import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SedeService {
  final Dio _dio;

  SedeService(this._dio);

  /// Crear nueva sede
  Future<Resource<Sede>> createSede(CreateSedeRequest request) async {
    try {
      if (kDebugMode) {
        print('📤 [SedeService] Creando sede: ${request.toJson()}');
      }

      final response = await _dio.post(
        '/api/sedes',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('📥 [SedeService] Response: ${response.statusCode}');
        if (kDebugMode) print('📦 [ZonaService] Data recibida');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final sede = Sede.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [SedeService] Sede creada: ${sede.nombre}');
          }

          return Success(sede);
        }

        return Error(responseData['message'] ?? 'Error al crear sede');
      }

      return Error('Error ${response.statusCode} al crear sede');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] DioException: ${e.message}');
        print('📦 [SedeService] Response: ${e.response?.data}');
      }

      // Manejo de errores del servidor
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          return Error(errorData['message']);
        }
      }

      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener todas las sedes
  Future<Resource<List<Sede>>> getSedes() async {
    try {
      if (kDebugMode) print('📍 [SedeService] Obteniendo sedes...');
      
      final response = await _dio.get('/api/sedes');
      
      if (kDebugMode) {
        print('✅ [SedeService] Response: ${response.statusCode}');
        if (kDebugMode) print('📦 [ZonaService] Data recibida');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final sedesData = dataWrapper['data'] as List;
          
          final sedes = sedesData.map((json) => Sede.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ [SedeService] ${sedes.length} sedes cargadas');
          }
          
          return Success(sedes);
        }
        
        return Error('Formato de respuesta inválido para sedes');
      }
      
      return Error('Error ${response.statusCode} obteniendo sedes');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener sedes por zona
  Future<Resource<List<Sede>>> getSedesByZona(int zonaId) async {
    try {
      if (kDebugMode) {
        print('📍 [SedeService] Obteniendo sedes de zona: $zonaId');
      }
      
      final response = await _dio.get('/api/sedes', queryParameters: {
        'zonaId': zonaId,
      });
      
      if (kDebugMode) {
        print('✅ [SedeService] Response: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final sedesData = dataWrapper['data'] as List;
          
          final sedes = sedesData.map((json) => Sede.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ [SedeService] ${sedes.length} sedes de zona $zonaId');
          }
          
          return Success(sedes);
        }
        
        return Error('Formato de respuesta inválido');
      }
      
      return Error('Error ${response.statusCode} obteniendo sedes');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
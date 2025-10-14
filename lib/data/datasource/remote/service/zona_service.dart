
import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ZonaService {
  final Dio _dio;

  ZonaService(this._dio);

  /// Crear nueva zona
  Future<Resource<Zona>> createZona(CreateZonaRequest request) async {
    try {
      if (kDebugMode) {
        print('📤 [ZonaService] Creando zona: ${request.toJson()}');
      }

      final response = await _dio.post(
        '/api/zonas',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('📥 [ZonaService] Response: ${response.statusCode}');
        print('📦 [ZonaService] Data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final zona = Zona.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [ZonaService] Zona creada: ${zona.nombre}');
          }

          return Success(zona);
        }

        return Error(responseData['message'] ?? 'Error al crear zona');
      }

      return Error('Error ${response.statusCode} al crear zona');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaService] DioException: ${e.message}');
        print('📦 [ZonaService] Response: ${e.response?.data}');
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
        print('❌ [ZonaService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener todas las zonas (ya existe en tu LocationService)
  Future<Resource<List<Zona>>> getZonas() async {
    try {
      if (kDebugMode) print('📍 [ZonaService] Obteniendo zonas...');
      
      final response = await _dio.get('/api/zonas');
      
      if (kDebugMode) {
        print('✅ [ZonaService] Response: ${response.statusCode}');
        print('📦 [ZonaService] Data: RECIBIDA}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final zonasData = dataWrapper['data'] as List;
          
          final zonas = zonasData.map((json) => Zona.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ [ZonaService] ${zonas.length} zonas cargadas');
          }
          
          return Success(zonas);
        }
        
        return Error('Formato de respuesta inválido para zonas');
      }
      
      return Error('Error ${response.statusCode} obteniendo zonas');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
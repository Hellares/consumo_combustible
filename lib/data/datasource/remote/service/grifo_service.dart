import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GrifoService {
  final Dio _dio;

  GrifoService(this._dio);

  /// Crear nuevo grifo
  Future<Resource<Grifo>> createGrifo(CreateGrifoRequest request) async {
    try {
      if (kDebugMode) {
        print('📤 [GrifoService] Creando grifo: ${request.nombre}');
      }

      final response = await _dio.post(
        '/api/grifos',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('📥 [GrifoService] Response: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final grifo = Grifo.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [GrifoService] Grifo creado: ${grifo.nombre}');
          }

          return Success(grifo);
        }

        return Error(responseData['message'] ?? 'Error al crear grifo');
      }

      return Error('Error ${response.statusCode} al crear grifo');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] DioException: ${e.message}');
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
        print('❌ [GrifoService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener todos los grifos
  Future<Resource<List<Grifo>>> getGrifos() async {
    try {
      if (kDebugMode) print('📍 [GrifoService] Obteniendo grifos...');
      
      final response = await _dio.get('/api/grifos');
      
      if (kDebugMode) {
        print('✅ [GrifoService] Response: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final grifosData = dataWrapper['data'] as List;
          
          final grifos = grifosData.map((json) => Grifo.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ [GrifoService] ${grifos.length} grifos cargados');
          }
          
          return Success(grifos);
        }
        
        return Error('Formato de respuesta inválido para grifos');
      }
      
      return Error('Error ${response.statusCode} obteniendo grifos');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener grifos por sede
  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId) async {
    try {
      if (kDebugMode) {
        print('📍 [GrifoService] Obteniendo grifos de sede: $sedeId');
      }
      
      final response = await _dio.get('/api/grifos', queryParameters: {
        'sedeId': sedeId,
      });
      
      if (kDebugMode) {
        print('✅ [GrifoService] Response: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final grifosData = dataWrapper['data'] as List;
          
          final grifos = grifosData.map((json) => Grifo.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ [GrifoService] ${grifos.length} grifos de sede $sedeId');
          }
          
          return Success(grifos);
        }
        
        return Error('Formato de respuesta inválido');
      }
      
      return Error('Error ${response.statusCode} obteniendo grifos');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener grifo por ID
  Future<Resource<Grifo>> getGrifoById(int id) async {
    try {
      if (kDebugMode) {
        print('📍 [GrifoService] Obteniendo grifo ID: $id');
      }
      
      final response = await _dio.get('/api/grifos/$id');
      
      if (kDebugMode) {
        print('✅ [GrifoService] Response: ${response.statusCode}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final grifo = Grifo.fromJson(responseData['data']);
          
          if (kDebugMode) {
            print('✅ [GrifoService] Grifo obtenido: ${grifo.nombre}');
          }
          
          return Success(grifo);
        }
        
        return Error('Formato de respuesta inválido');
      }
      
      return Error('Error ${response.statusCode} obteniendo grifo');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] DioException: ${e.message}');
      }
      
      final errorMsg = e.response?.statusMessage ?? 
          e.message ?? 
          'Error de conexión';
      return Error(errorMsg);
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Actualizar grifo
  Future<Resource<Grifo>> updateGrifo(int id, CreateGrifoRequest request) async {
    try {
      if (kDebugMode) {
        print('📤 [GrifoService] Actualizando grifo ID: $id');
      }

      final response = await _dio.patch(
        '/api/grifos/$id',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('📥 [GrifoService] Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final grifo = Grifo.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ [GrifoService] Grifo actualizado: ${grifo.nombre}');
          }

          return Success(grifo);
        }

        return Error(responseData['message'] ?? 'Error al actualizar grifo');
      }

      return Error('Error ${response.statusCode} al actualizar grifo');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoService] DioException: ${e.message}');
      }

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
        print('❌ [GrifoService] Error general: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
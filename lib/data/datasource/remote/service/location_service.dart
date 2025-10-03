import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  final Dio _dio;

  LocationService(this._dio);

  // Future<Resource<List<Zona>>> getZonas() async {
  //   try {
  //     final response = await _dio.get('/api/zonas');
      
  //     if (response.statusCode == 200) {
  //       final data = response.data['data']['data'] as List;
  //       final zonas = data.map((json) => Zona.fromJson(json)).toList();
  //       return Success(zonas);
  //     }
      
  //     return Error('Error obteniendo zonas');
  //   } catch (e) {
  //     return Error('Error de conexión: $e');
  //   }
  // }
  Future<Resource<List<Zona>>> getZonas() async {
    try {
      if (kDebugMode) print('📍 Obteniendo zonas...');
      
      final response = await _dio.get('/api/zonas');
      
      if (kDebugMode) {
        print('✅ Response zonas: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }
      
      if (response.statusCode == 200) {
        // ✅ Estructura: { "success": true, "data": { "data": [...] } }
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final dataWrapper = responseData['data'];
          final zonasData = dataWrapper['data'] as List;
          
          final zonas = zonasData.map((json) => Zona.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ ${zonas.length} zonas cargadas');
          }
          
          return Success(zonas);
        }
        
        return Error('Formato de respuesta inválido para zonas');
      }
      
      return Error('Error ${response.statusCode} obteniendo zonas');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getZonas: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('Endpoint no encontrado');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }
      
      return Error('Error de conexión: ${e.message}');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error general en getZonas: $e');
      return Error('Error inesperado: $e');
    }
  }

  // Future<Resource<List<Sede>>> getSedesByZona(int zonaId) async {
  //   try {
  //     final response = await _dio.get('/api/sedes/zona/$zonaId');
      
  //     if (response.statusCode == 200) {
  //       final data = response.data['data'] as List;
  //       final sedes = data.map((json) => Sede.fromJson(json)).toList();
  //       return Success(sedes);
  //     }
      
  //     return Error('Error obteniendo sedes');
  //   } catch (e) {
  //     return Error('Error de conexión: $e');
  //   }
  // }

  Future<Resource<List<Sede>>> getSedesByZona(int zonaId) async {
    try {
      if (kDebugMode) print('🏢 Obteniendo sedes para zona $zonaId...');
      
      final response = await _dio.get('/api/sedes/zona/$zonaId');
      
      if (kDebugMode) {
        print('✅ Response sedes: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // ✅ La data viene directamente como array, no dentro de otro "data"
          final sedesData = responseData['data'] as List;
          
          final sedes = sedesData.map((json) => Sede.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ ${sedes.length} sedes cargadas para zona $zonaId');
          }
          
          return Success(sedes);
        }
        
        return Error('Formato de respuesta inválido para sedes');
      }
      
      return Error('Error ${response.statusCode} obteniendo sedes');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getSedesByZona: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('No se encontraron sedes para esta zona');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }
      
      return Error('Error de conexión: ${e.message}');
      
    } catch (e) {
      if (kDebugMode) print('❌ Error general en getSedesByZona: $e');
      return Error('Error inesperado: $e');
    }
  }

  // Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId) async {
  //   try {
  //     final response = await _dio.get('/api/grifos/sede/$sedeId');
      
  //     if (response.statusCode == 200) {
  //       final data = response.data['data'] as List;
  //       final grifos = data.map((json) => Grifo.fromJson(json)).toList();
  //       return Success(grifos);
  //     }
      
  //     return Error('Error obteniendo grifos');
  //   } catch (e) {
  //     return Error('Error de conexión: $e');
  //   }
  // }

  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId) async {
    try {
      if (kDebugMode) print('⛽ Obteniendo grifos para sede $sedeId...');
      
      final response = await _dio.get('/api/grifos/sede/$sedeId');
      
      if (kDebugMode) {
        print('✅ Response grifos: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // ✅ La data viene directamente como array
          final grifosData = responseData['data'] as List;
          
          final grifos = grifosData.map((json) => Grifo.fromJson(json)).toList();
          
          if (kDebugMode) {
            print('✅ ${grifos.length} grifos cargados para sede $sedeId');
            for (var grifo in grifos) {
              print('   - ${grifo.nombre} (${grifo.codigo})');
            }
          }
          
          return Success(grifos);
        }
        
        return Error('Formato de respuesta inválido para grifos');
      }
      
      return Error('Error ${response.statusCode} obteniendo grifos');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getGrifosBySede: ${e.message}');
        print('❌ Type: ${e.type}');
        print('❌ Response: ${e.response?.data}');
        print('❌ Status Code: ${e.response?.statusCode}');
      }
      
      if (e.type == DioExceptionType.connectionTimeout) {
        return Error('Tiempo de conexión agotado');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de respuesta agotado');
      } else if (e.response?.statusCode == 404) {
        return Error('No se encontraron grifos para esta sede');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }
      
      return Error('Error de conexión: ${e.message}');
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en getGrifosBySede: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }

}


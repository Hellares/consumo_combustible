// =============================================
// GPS Service - API REST
// =============================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:consumo_combustible/domain/models/gps_stats.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GpsService {
  final Dio _dio;

  GpsService(this._dio);

  // ==========================================
  // ENVIAR UBICACIÓN
  // ==========================================

  /// Enviar ubicación GPS (REST - Backup)
  Future<Resource<GpsLocation>> sendLocation(GpsLocation location) async {
    try {
      if (kDebugMode) {
        print('📍 Enviando ubicación: Unidad ${location.unidadId}');
      }

      final response = await _dio.post(
        '/api/gps/location',
        data: location.toJson(),
      );

      if (kDebugMode) {
        print('✅ Ubicación enviada: ${response.statusCode}');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final locationData = GpsLocation.fromJson(responseData['data']);
          return Success(locationData);
        }

        return Error(responseData['message'] ?? 'Error al enviar ubicación');
      }

      return Error('Error ${response.statusCode}: ${response.statusMessage}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException enviando ubicación: ${e.message}');
      }

      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          return Error(message ?? 'Error $statusCode al enviar ubicación');
        }

        return Error('Error $statusCode: ${e.response?.statusMessage}');
      }

      // Sin respuesta del servidor
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return Error('Tiempo de espera agotado');
      }

      if (e.type == DioExceptionType.connectionError) {
        return Error('Error de conexión. Verifica tu internet');
      }

      return Error('Error de red: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado enviando ubicación: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Enviar múltiples ubicaciones (Batch)
  Future<Resource<int>> sendLocationBatch(List<GpsLocation> locations) async {
    try {
      if (kDebugMode) {
        print('📦 Enviando batch de ${locations.length} ubicaciones');
      }

      final response = await _dio.post(
        '/api/gps/location/batch',
        data: locations.map((loc) => loc.toJson()).toList(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final count = responseData['data']['count'] as int;
          
          if (kDebugMode) {
            print('✅ Batch enviado: $count ubicaciones guardadas');
          }

          return Success(count);
        }

        return Error(responseData['message'] ?? 'Error al enviar batch');
      }

      return Error('Error ${response.statusCode}: ${response.statusMessage}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en batch: ${e.message}');
      }

      if (e.response != null) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final message = responseData['message'] as String?;
          return Error(message ?? 'Error al enviar batch');
        }
      }

      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado en batch: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // ==========================================
  // CONSULTAR UBICACIONES ACTUALES
  // ==========================================

  /// Obtener ubicación actual de una unidad
  Future<Resource<UnidadTracking>> getCurrentLocation(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 Obteniendo ubicación actual: Unidad $unidadId');
      }

      final response = await _dio.get('/api/gps/current/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final unidad = UnidadTracking.fromJson(responseData['data']);
          
          if (kDebugMode) {
            print('✅ Ubicación obtenida: ${unidad.placa}');
          }

          return Success(unidad);
        }

        return Error(responseData['message'] ?? 'Error obteniendo ubicación');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo ubicación: ${e.message}');
      }

      if (e.response?.statusCode == 404) {
        return Error('Unidad no encontrada');
      }

      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener ubicaciones actuales de múltiples unidades
  Future<Resource<UnidadesTrackingList>> getCurrentLocations({
    List<int>? unidadesIds,
    int? zonaId,
    bool soloActivas = false,
    GpsProviderType? proveedor,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 Obteniendo ubicaciones actuales');
      }

      final queryParams = <String, dynamic>{};

      if (unidadesIds != null && unidadesIds.isNotEmpty) {
        queryParams['unidadesIds'] = unidadesIds.join(',');
      }

      if (zonaId != null) {
        queryParams['zonaId'] = zonaId;
      }

      if (soloActivas) {
        queryParams['soloActivas'] = true;
      }

      if (proveedor != null) {
        queryParams['proveedor'] = proveedor.value;
      }

      final response = await _dio.get(
        '/api/gps/current',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final list = UnidadesTrackingList.fromJson(responseData['data']);
          
          if (kDebugMode) {
            print('✅ ${list.total} ubicaciones obtenidas');
          }

          return Success(list);
        }

        return Error(responseData['message'] ?? 'Error obteniendo ubicaciones');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo ubicaciones: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener última ubicación de una unidad
  Future<Resource<GpsLocation?>> getLastLocation(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 Obteniendo última ubicación: Unidad $unidadId');
      }

      final response = await _dio.get('/api/gps/last/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true) {
          if (responseData['data'] == null) {
            return Success(null);
          }

          final location = GpsLocation.fromJson(responseData['data']);
          return Success(location);
        }

        return Error(responseData['message'] ?? 'Error obteniendo ubicación');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo última ubicación: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // ==========================================
  // HISTORIAL
  // ==========================================

  /// Obtener historial de ubicaciones
  Future<Resource<List<GpsLocation>>> getLocationHistory({
    int? unidadId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    GpsProviderType? proveedor,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      if (kDebugMode) {
        print('📜 Obteniendo historial de ubicaciones');
      }

      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (unidadId != null) {
        queryParams['unidadId'] = unidadId;
      }

      if (fechaInicio != null) {
        queryParams['fechaInicio'] = fechaInicio.toIso8601String();
      }

      if (fechaFin != null) {
        queryParams['fechaFin'] = fechaFin.toIso8601String();
      }

      if (proveedor != null) {
        queryParams['proveedor'] = proveedor.value;
      }

      final response = await _dio.get(
        '/api/gps/history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          final locations = (data['data'] as List)
              .map((item) => GpsLocation.fromJson(item))
              .toList();

          if (kDebugMode) {
            print('✅ ${locations.length} ubicaciones históricas obtenidas');
          }

          return Success(locations);
        }

        return Error(responseData['message'] ?? 'Error obteniendo historial');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo historial: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================

  /// Obtener estadísticas generales
  Future<Resource<GpsStats>> getTrackingStats() async {
    try {
      if (kDebugMode) {
        print('📊 Obteniendo estadísticas GPS');
      }

      final response = await _dio.get('/api/gps/stats');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final stats = GpsStats.fromJson(responseData['data']);
          
          if (kDebugMode) {
            print('✅ Estadísticas obtenidas: ${stats.totalUnidades} unidades');
          }

          return Success(stats);
        }

        return Error(responseData['message'] ?? 'Error obteniendo estadísticas');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estadísticas: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener estado de tracking de una unidad
  Future<Resource<TrackingStatus>> getTrackingStatus(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 Obteniendo estado: Unidad $unidadId');
      }

      final response = await _dio.get('/api/gps/status/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final status = TrackingStatus.fromJson(responseData['data']);
          return Success(status);
        }

        return Error(responseData['message'] ?? 'Error obteniendo estado');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error obteniendo estado: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Verificar si unidad está activa
  Future<Resource<bool>> isUnitActive(int unidadId) async {
    try {
      final response = await _dio.get('/api/gps/active/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final isActive = responseData['data']['isActive'] as bool;
          return Success(isActive);
        }

        return Error(responseData['message'] ?? 'Error verificando estado');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      return Error('Error inesperado: $e');
    }
  }

  /// Verificar si tiene GPS vehicular activo
  Future<Resource<bool>> hasActiveGpsDevice(int unidadId) async {
    try {
      final response = await _dio.get('/api/gps/device/$unidadId');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final hasGpsDevice = responseData['data']['hasGpsDevice'] as bool;
          return Success(hasGpsDevice);
        }

        return Error(responseData['message'] ?? 'Error verificando GPS device');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener unidades inactivas
  Future<Resource<List<int>>> getInactiveUnits({int minutesThreshold = 60}) async {
    try {
      final response = await _dio.get(
        '/api/gps/inactive',
        queryParameters: {'minutes': minutesThreshold},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final unidadesIds = (responseData['data']['unidadesIds'] as List)
              .map((id) => id as int)
              .toList();

          return Success(unidadesIds);
        }

        return Error(responseData['message'] ?? 'Error obteniendo inactivas');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      return Error('Error inesperado: $e');
    }
  }

  // ==========================================
  // MANTENIMIENTO (ADMIN)
  // ==========================================

  /// Limpiar ubicaciones antiguas
  Future<Resource<int>> cleanOldLocations({int days = 30}) async {
    try {
      if (kDebugMode) {
        print('🗑️ Limpiando ubicaciones > $days días');
      }

      final response = await _dio.delete(
        '/api/gps/cleanup',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final deletedCount = responseData['data']['deletedCount'] as int;
          
          if (kDebugMode) {
            print('✅ $deletedCount ubicaciones eliminadas');
          }

          return Success(deletedCount);
        }

        return Error(responseData['message'] ?? 'Error limpiando datos');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ Error limpiando datos: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error inesperado: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Health check
  Future<Resource<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/api/gps/health');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          return Success(Map<String, dynamic>.from(responseData['data']));
        }

        return Error(responseData['message'] ?? 'Error en health check');
      }

      return Error('Error ${response.statusCode}');
    } on DioException catch (e) {
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      return Error('Error inesperado: $e');
    }
  }
}
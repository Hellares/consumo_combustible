// =============================================
// GPS Repository Implementation
// Combina REST (backup) + WebSocket (tiempo real)
// =============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/models/gps_stats.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/data/datasource/remote/service/gps_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/gps_socket_service.dart';

class GpsRepositoryImpl implements GpsRepository {
  final GpsService _gpsService;
  final GpsSocketService _gpsSocketService;

  GpsRepositoryImpl({
    required GpsService gpsService,
    required GpsSocketService gpsSocketService,
  })  : _gpsService = gpsService,
        _gpsSocketService = gpsSocketService;

  // ==========================================
  // ENVIAR UBICACIÓN
  // ==========================================

  @override
  Future<Resource<GpsLocation>> sendLocation(GpsLocation location) async {
    try {
      // Prioridad 1: Intentar enviar por WebSocket (más rápido)
      if (_gpsSocketService.isWebSocketConnected()) {
        try {
          await _gpsSocketService.sendLocation(location);
          
          if (kDebugMode) {
            print('✅ [Repo] Ubicación enviada por WebSocket');
          }

          // Retornar la ubicación enviada (sin ID del servidor por WebSocket)
          return Success(location);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [Repo] Error enviando por WebSocket, intentando REST: $e');
          }
          // Si falla WebSocket, continuar con REST
        }
      }

      // Prioridad 2: Fallback a REST API
      if (kDebugMode) {
        print('📡 [Repo] Enviando ubicación por REST');
      }

      return await _gpsService.sendLocation(location);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error enviando ubicación: $e');
      }
      return Error('Error enviando ubicación: $e');
    }
  }

  @override
  Future<Resource<int>> sendLocationBatch(List<GpsLocation> locations) async {
    try {
      if (kDebugMode) {
        print('📦 [Repo] Enviando batch de ${locations.length} ubicaciones');
      }

      // Batch siempre por REST (más confiable para múltiples ubicaciones)
      return await _gpsService.sendLocationBatch(locations);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error enviando batch: $e');
      }
      return Error('Error enviando batch: $e');
    }
  }

  // ==========================================
  // CONSULTAR UBICACIONES ACTUALES
  // ==========================================

  @override
  Future<Resource<UnidadTracking>> getCurrentLocation(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 [Repo] Obteniendo ubicación actual: Unidad $unidadId');
      }

      return await _gpsService.getCurrentLocation(unidadId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo ubicación: $e');
      }
      return Error('Error obteniendo ubicación: $e');
    }
  }

  @override
  Future<Resource<UnidadesTrackingList>> getCurrentLocations({
    List<int>? unidadesIds,
    int? zonaId,
    bool soloActivas = false,
    GpsProviderType? proveedor,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 [Repo] Obteniendo ubicaciones actuales');
      }

      return await _gpsService.getCurrentLocations(
        unidadesIds: unidadesIds,
        zonaId: zonaId,
        soloActivas: soloActivas,
        proveedor: proveedor,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo ubicaciones: $e');
      }
      return Error('Error obteniendo ubicaciones: $e');
    }
  }

  @override
  Future<Resource<GpsLocation?>> getLastLocation(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 [Repo] Obteniendo última ubicación: Unidad $unidadId');
      }

      return await _gpsService.getLastLocation(unidadId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo última ubicación: $e');
      }
      return Error('Error obteniendo última ubicación: $e');
    }
  }

  // ==========================================
  // HISTORIAL
  // ==========================================

  @override
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
        print('📜 [Repo] Obteniendo historial de ubicaciones');
      }

      return await _gpsService.getLocationHistory(
        unidadId: unidadId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        proveedor: proveedor,
        page: page,
        pageSize: pageSize,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo historial: $e');
      }
      return Error('Error obteniendo historial: $e');
    }
  }

  // ==========================================
  // ESTADÍSTICAS
  // ==========================================

  @override
  Future<Resource<GpsStats>> getTrackingStats() async {
    try {
      if (kDebugMode) {
        print('📊 [Repo] Obteniendo estadísticas GPS');
      }

      return await _gpsService.getTrackingStats();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo estadísticas: $e');
      }
      return Error('Error obteniendo estadísticas: $e');
    }
  }

  @override
  Future<Resource<TrackingStatus>> getTrackingStatus(int unidadId) async {
    try {
      if (kDebugMode) {
        print('🔍 [Repo] Obteniendo estado de tracking: Unidad $unidadId');
      }

      return await _gpsService.getTrackingStatus(unidadId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo estado: $e');
      }
      return Error('Error obteniendo estado: $e');
    }
  }

  @override
  Future<Resource<bool>> isUnitActive(int unidadId) async {
    try {
      return await _gpsService.isUnitActive(unidadId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error verificando si está activa: $e');
      }
      return Error('Error verificando estado: $e');
    }
  }

  @override
  Future<Resource<bool>> hasActiveGpsDevice(int unidadId) async {
    try {
      return await _gpsService.hasActiveGpsDevice(unidadId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error verificando GPS device: $e');
      }
      return Error('Error verificando GPS device: $e');
    }
  }

  @override
  Future<Resource<List<int>>> getInactiveUnits({int minutesThreshold = 60}) async {
    try {
      if (kDebugMode) {
        print('🔍 [Repo] Obteniendo unidades inactivas (>${minutesThreshold}min)');
      }

      return await _gpsService.getInactiveUnits(
        minutesThreshold: minutesThreshold,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error obteniendo unidades inactivas: $e');
      }
      return Error('Error obteniendo unidades inactivas: $e');
    }
  }

  // ==========================================
  // MANTENIMIENTO (ADMIN)
  // ==========================================

  @override
  Future<Resource<int>> cleanOldLocations({int days = 30}) async {
    try {
      if (kDebugMode) {
        print('🗑️ [Repo] Limpiando ubicaciones antiguas (>$days días)');
      }

      return await _gpsService.cleanOldLocations(days: days);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error limpiando ubicaciones: $e');
      }
      return Error('Error limpiando ubicaciones: $e');
    }
  }

  @override
  Future<Resource<Map<String, dynamic>>> healthCheck() async {
    try {
      return await _gpsService.healthCheck();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error en health check: $e');
      }
      return Error('Error en health check: $e');
    }
  }

  // ==========================================
  // WEBSOCKET (TIEMPO REAL)
  // ==========================================

  @override
  Future<Resource<void>> connectWebSocket(String token) async {
    try {
      if (kDebugMode) {
        print('🔌 [Repo] Conectando WebSocket...');
      }

      final result = await _gpsSocketService.connect(token);

      if (result is Success) {
        if (kDebugMode) {
          print('✅ [Repo] WebSocket conectado exitosamente');
        }
        return Success(null);
      } else if (result is Error) {
        if (kDebugMode) {
          print('❌ [Repo] Error conectando WebSocket: ${result.message}');
        }
        return Error(result.message);
      }

      return Error('Error desconocido conectando WebSocket');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Excepción conectando WebSocket: $e');
      }
      return Error('Error conectando WebSocket: $e');
    }
  }

  @override
  Future<void> disconnectWebSocket() async {
    try {
      if (kDebugMode) {
        print('🔌 [Repo] Desconectando WebSocket...');
      }

      await _gpsSocketService.disconnect();

      if (kDebugMode) {
        print('✅ [Repo] WebSocket desconectado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error desconectando WebSocket: $e');
      }
    }
  }

  @override
  bool isWebSocketConnected() {
    return _gpsSocketService.isWebSocketConnected();
  }

  // ==========================================
  // STREAMS DE TIEMPO REAL
  // ==========================================

  @override
  Stream<UnidadTracking> get locationUpdatesStream {
    return _gpsSocketService.locationUpdatesStream;
  }

  @override
  Stream<bool> get connectionStatusStream {
    return _gpsSocketService.connectionStatusStream;
  }

  @override
  Stream<GpsDeviceStatus> get gpsDeviceStatusStream {
    return _gpsSocketService.gpsDeviceStatusStream;
  }

  // ==========================================
  // SUSCRIPCIONES A TRACKING
  // ==========================================

  @override
  Future<void> subscribeToTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
  }) async {
    try {
      if (!_gpsSocketService.isWebSocketConnected()) {
        if (kDebugMode) {
          print('⚠️ [Repo] No conectado a WebSocket, no se puede suscribir');
        }
        throw Exception('WebSocket no conectado. Conecta primero.');
      }

      if (kDebugMode) {
        print('📡 [Repo] Suscribiendo a tracking...');
        if (all) print('   Modo: TODAS las unidades');
        if (zonaId != null) print('   Zona: $zonaId');
        if (unidadesIds != null) print('   Unidades: $unidadesIds');
      }

      await _gpsSocketService.subscribeToTracking(
        unidadesIds: unidadesIds,
        zonaId: zonaId,
        all: all,
      );

      if (kDebugMode) {
        print('✅ [Repo] Suscripción enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error suscribiendo a tracking: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
  }) async {
    try {
      if (!_gpsSocketService.isWebSocketConnected()) {
        if (kDebugMode) {
          print('⚠️ [Repo] No conectado, no se puede desuscribir');
        }
        return; // No lanzar error, solo retornar
      }

      if (kDebugMode) {
        print('📡 [Repo] Desuscribiendo de tracking...');
      }

      await _gpsSocketService.unsubscribeFromTracking(
        unidadesIds: unidadesIds,
        zonaId: zonaId,
        all: all,
      );

      if (kDebugMode) {
        print('✅ [Repo] Desuscripción enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error desuscribiendo: $e');
      }
      // No relanzar error en desuscripción
    }
  }

  @override
  Future<void> subscribeToUnit(int unidadId) async {
    try {
      if (!_gpsSocketService.isWebSocketConnected()) {
        if (kDebugMode) {
          print('⚠️ [Repo] No conectado, no se puede suscribir a unidad');
        }
        throw Exception('WebSocket no conectado');
      }

      if (kDebugMode) {
        print('📡 [Repo] Suscribiendo a unidad $unidadId...');
      }

      await _gpsSocketService.subscribeToUnit(unidadId);

      if (kDebugMode) {
        print('✅ [Repo] Suscrito a unidad $unidadId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error suscribiendo a unidad: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> unsubscribeFromUnit(int unidadId) async {
    try {
      if (!_gpsSocketService.isWebSocketConnected()) {
        if (kDebugMode) {
          print('⚠️ [Repo] No conectado, no se puede desuscribir de unidad');
        }
        return;
      }

      if (kDebugMode) {
        print('📡 [Repo] Desuscribiendo de unidad $unidadId...');
      }

      await _gpsSocketService.unsubscribeFromUnit(unidadId);

      if (kDebugMode) {
        print('✅ [Repo] Desuscrito de unidad $unidadId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error desuscribiendo de unidad: $e');
      }
    }
  }

  @override
  Future<void> requestUnitStatus(int unidadId) async {
    try {
      if (!_gpsSocketService.isWebSocketConnected()) {
        if (kDebugMode) {
          print('⚠️ [Repo] No conectado, no se puede solicitar estado');
        }
        throw Exception('WebSocket no conectado');
      }

      if (kDebugMode) {
        print('📡 [Repo] Solicitando estado de unidad $unidadId...');
      }

      await _gpsSocketService.requestUnitStatus(unidadId);

      if (kDebugMode) {
        print('✅ [Repo] Solicitud de estado enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Error solicitando estado: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  /// Obtener información detallada de la conexión WebSocket
  Map<String, dynamic> getWebSocketInfo() {
    return _gpsSocketService.getConnectionInfo();
  }

  /// Reconectar WebSocket (útil para retry logic)
  Future<Resource<void>> reconnectWebSocket() async {
    try {
      if (kDebugMode) {
        print('🔄 [Repo] Reconectando WebSocket...');
      }

      final result = await _gpsSocketService.reconnect();

      if (result is Success) {
        if (kDebugMode) {
          print('✅ [Repo] WebSocket reconectado');
        }
        return Success(null);
      } else if (result is Error) {
        if (kDebugMode) {
          print('❌ [Repo] Error reconectando: ${result.message}');
        }
        return Error(result.message);
      }

      return Error('Error desconocido al reconectar');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Repo] Excepción al reconectar: $e');
      }
      return Error('Error al reconectar: $e');
    }
  }

  /// Dispose (limpiar recursos)
  void dispose() {
    if (kDebugMode) {
      print('🗑️ [Repo] Dispose - Limpiando recursos');
    }

    _gpsSocketService.dispose();
  }
}
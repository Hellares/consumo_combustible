// =============================================
// GPS States
// Estados posibles del módulo GPS
// =============================================

import 'package:equatable/equatable.dart';
import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:consumo_combustible/domain/models/gps_stats.dart';

abstract class GpsState extends Equatable {
  const GpsState();

  @override
  List<Object?> get props => [];
}

// ==========================================
// ESTADOS INICIALES
// ==========================================

/// Estado inicial
class GpsInitial extends GpsState {
  const GpsInitial();
}

// ==========================================
// ESTADOS DE CONEXIÓN WEBSOCKET
// ==========================================

/// Conectando al WebSocket
class GpsConnecting extends GpsState {
  const GpsConnecting();
}

/// WebSocket conectado
class GpsConnected extends GpsState {
  final bool isSubscribed;
  final DateTime connectedAt;

  const GpsConnected({
    this.isSubscribed = false,
    required this.connectedAt,
  });

  @override
  List<Object?> get props => [isSubscribed, connectedAt];

  GpsConnected copyWith({
    bool? isSubscribed,
    DateTime? connectedAt,
  }) {
    return GpsConnected(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      connectedAt: connectedAt ?? this.connectedAt,
    );
  }
}

/// WebSocket desconectado
class GpsDisconnected extends GpsState {
  final String? reason;

  const GpsDisconnected({this.reason});

  @override
  List<Object?> get props => [reason];
}

// ==========================================
// ESTADOS DE UBICACIONES EN TIEMPO REAL
// ==========================================

/// Recibiendo ubicaciones en tiempo real
class GpsReceivingUpdates extends GpsState {
  final List<UnidadTracking> unidades;
  final DateTime lastUpdate;
  final bool isConnected;
  final int totalUnidades;

  const GpsReceivingUpdates({
    required this.unidades,
    required this.lastUpdate,
    required this.isConnected,
    required this.totalUnidades,
  });

  @override
  List<Object?> get props => [unidades, lastUpdate, isConnected, totalUnidades];

  /// Agregar o actualizar una unidad
  /// ✅ CORRECCIÓN CRÍTICA: Fusiona datos del WebSocket con datos existentes
  /// para preservar información como placa, conductor, etc.
  GpsReceivingUpdates updateUnidad(UnidadTracking newUnidad) {
    final updatedList = List<UnidadTracking>.from(unidades);
    final index = updatedList.indexWhere((u) => u.unidadId == newUnidad.unidadId);

    if (index != -1) {
      // ✅ FUSIONAR: Mantener datos existentes y solo actualizar ubicación
      final existingUnidad = updatedList[index];
      
      updatedList[index] = UnidadTracking(
        unidadId: newUnidad.unidadId,
        // ✅ Preservar placa existente si la nueva está vacía
        placa: newUnidad.placa.isNotEmpty ? newUnidad.placa : existingUnidad.placa,
        // ✅ Actualizar ubicación (lo más importante)
        ultimaUbicacion: newUnidad.ultimaUbicacion ?? existingUnidad.ultimaUbicacion,
        // ✅ Actualizar tiempo y estado
        tiempoTranscurrido: newUnidad.tiempoTranscurrido,
        estado: newUnidad.estado,
        // ✅ Preservar conductor existente si el nuevo es null
        conductor: newUnidad.conductor ?? existingUnidad.conductor,
      );
    } else {
      // Agregar nueva unidad (no estaba en la lista inicial)
      updatedList.add(newUnidad);
    }

    return GpsReceivingUpdates(
      unidades: updatedList,
      lastUpdate: DateTime.now(),
      isConnected: isConnected,
      totalUnidades: updatedList.length,
    );
  }

  GpsReceivingUpdates copyWith({
    List<UnidadTracking>? unidades,
    DateTime? lastUpdate,
    bool? isConnected,
    int? totalUnidades,
  }) {
    return GpsReceivingUpdates(
      unidades: unidades ?? this.unidades,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      isConnected: isConnected ?? this.isConnected,
      totalUnidades: totalUnidades ?? this.totalUnidades,
    );
  }
}

// ==========================================
// ESTADOS DE ENVÍO DE UBICACIÓN
// ==========================================

/// Enviando ubicación
class GpsSendingLocation extends GpsState {
  const GpsSendingLocation();
}

/// Ubicación enviada exitosamente
class GpsLocationSent extends GpsState {
  final GpsLocation location;
  final DateTime sentAt;

  const GpsLocationSent({
    required this.location,
    required this.sentAt,
  });

  @override
  List<Object?> get props => [location, sentAt];
}

/// Tracking automático activo
class GpsTrackingActive extends GpsState {
  final int unidadId;
  final DateTime startedAt;
  final int locationsSent;
  final DateTime? lastLocationSentAt;

  const GpsTrackingActive({
    required this.unidadId,
    required this.startedAt,
    this.locationsSent = 0,
    this.lastLocationSentAt,
  });

  @override
  List<Object?> get props => [unidadId, startedAt, locationsSent, lastLocationSentAt];

  GpsTrackingActive copyWith({
    int? unidadId,
    DateTime? startedAt,
    int? locationsSent,
    DateTime? lastLocationSentAt,
  }) {
    return GpsTrackingActive(
      unidadId: unidadId ?? this.unidadId,
      startedAt: startedAt ?? this.startedAt,
      locationsSent: locationsSent ?? this.locationsSent,
      lastLocationSentAt: lastLocationSentAt ?? this.lastLocationSentAt,
    );
  }

  GpsTrackingActive incrementSent() {
    return copyWith(
      locationsSent: locationsSent + 1,
      lastLocationSentAt: DateTime.now(),
    );
  }
}

// ==========================================
// ESTADOS DE CONSULTA (REST)
// ==========================================

/// Cargando ubicaciones actuales
class GpsLoadingLocations extends GpsState {
  const GpsLoadingLocations();
}

/// Ubicaciones actuales cargadas
class GpsLocationsLoaded extends GpsState {
  final UnidadesTrackingList data;
  final DateTime loadedAt;

  const GpsLocationsLoaded({
    required this.data,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [data, loadedAt];
}

/// Cargando historial
class GpsLoadingHistory extends GpsState {
  const GpsLoadingHistory();
}

/// Historial cargado
class GpsHistoryLoaded extends GpsState {
  final List<GpsLocation> locations;
  final int unidadId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final DateTime loadedAt;

  const GpsHistoryLoaded({
    required this.locations,
    required this.unidadId,
    this.fechaInicio,
    this.fechaFin,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [locations, unidadId, fechaInicio, fechaFin, loadedAt];
}

// ==========================================
// ESTADOS DE ESTADÍSTICAS
// ==========================================

/// Cargando estadísticas
class GpsLoadingStats extends GpsState {
  const GpsLoadingStats();
}

/// Estadísticas cargadas
class GpsStatsLoaded extends GpsState {
  final GpsStats stats;
  final DateTime loadedAt;

  const GpsStatsLoaded({
    required this.stats,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [stats, loadedAt];
}

/// Estado de unidad cargado
class GpsUnitStatusLoaded extends GpsState {
  final TrackingStatus status;
  final DateTime loadedAt;

  const GpsUnitStatusLoaded({
    required this.status,
    required this.loadedAt,
  });

  @override
  List<Object?> get props => [status, loadedAt];
}

// ==========================================
// ESTADOS DE ERROR
// ==========================================

/// Error general
class GpsError extends GpsState {
  final String message;
  final String? code;
  final DateTime occurredAt;

  const GpsError({
    required this.message,
    this.code,
    required this.occurredAt,
  });

  @override
  List<Object?> get props => [message, code, occurredAt];
}

/// Error de conexión WebSocket
class GpsConnectionError extends GpsState {
  final String message;
  final bool canRetry;

  const GpsConnectionError({
    required this.message,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, canRetry];
}

/// Error al enviar ubicación
class GpsSendLocationError extends GpsState {
  final String message;
  final GpsLocation? failedLocation;

  const GpsSendLocationError({
    required this.message,
    this.failedLocation,
  });

  @override
  List<Object?> get props => [message, failedLocation];
}
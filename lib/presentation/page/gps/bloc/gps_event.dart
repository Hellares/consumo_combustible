// =============================================
// GPS Events
// Eventos que dispara la UI
// =============================================

import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:equatable/equatable.dart';
import 'package:consumo_combustible/domain/models/gps_location.dart';

abstract class GpsEvent extends Equatable {
  const GpsEvent();

  @override
  List<Object?> get props => [];
}

// ==========================================
// CONEXIÓN WEBSOCKET
// ==========================================

/// Conectar al WebSocket
class ConnectWebSocketEvent extends GpsEvent {
  final String token;
  final bool? autoSubscribe;

  const ConnectWebSocketEvent(
    this.token, {
    this.autoSubscribe = true, // ✅ Por defecto true
  });

  @override
  List<Object?> get props => [token, autoSubscribe];
}

/// Desconectar del WebSocket
class DisconnectWebSocketEvent extends GpsEvent {
  const DisconnectWebSocketEvent();
}

/// Reconectar WebSocket
class ReconnectWebSocketEvent extends GpsEvent {
  const ReconnectWebSocketEvent();
}

// ==========================================
// SUSCRIPCIONES
// ==========================================

/// Suscribirse a tracking de todas las unidades
class SubscribeToAllUnitsEvent extends GpsEvent {
  const SubscribeToAllUnitsEvent();
}

/// Suscribirse a unidades de una zona
class SubscribeToZoneEvent extends GpsEvent {
  final int zonaId;

  const SubscribeToZoneEvent(this.zonaId);

  @override
  List<Object?> get props => [zonaId];
}

/// Suscribirse a unidades específicas
class SubscribeToUnitsEvent extends GpsEvent {
  final List<int> unidadesIds;

  const SubscribeToUnitsEvent(this.unidadesIds);

  @override
  List<Object?> get props => [unidadesIds];
}

/// Suscribirse a una unidad específica
class SubscribeToUnitEvent extends GpsEvent {
  final int unidadId;

  const SubscribeToUnitEvent(this.unidadId);

  @override
  List<Object?> get props => [unidadId];
}

/// Desuscribirse de tracking
class UnsubscribeFromTrackingEvent extends GpsEvent {
  final bool all;
  final int? zonaId;
  final List<int>? unidadesIds;

  const UnsubscribeFromTrackingEvent({
    this.all = false,
    this.zonaId,
    this.unidadesIds,
  });

  @override
  List<Object?> get props => [all, zonaId, unidadesIds];
}

// ==========================================
// ENVIAR UBICACIÓN
// ==========================================

/// Enviar ubicación GPS (Conductor)
class SendLocationEvent extends GpsEvent {
  final GpsLocation location;

  const SendLocationEvent(this.location);

  @override
  List<Object?> get props => [location];
}

/// Iniciar envío automático de ubicaciones
class StartLocationTrackingEvent extends GpsEvent {
  final int unidadId;
  final Duration interval; // Intervalo de envío

  const StartLocationTrackingEvent({
    required this.unidadId,
    this.interval = const Duration(seconds: 10),
  });

  @override
  List<Object?> get props => [unidadId, interval];
}

/// Detener envío automático
class StopLocationTrackingEvent extends GpsEvent {
  const StopLocationTrackingEvent();
}

// ==========================================
// CONSULTAR UBICACIONES (REST)
// ==========================================

/// Cargar ubicaciones actuales
class LoadCurrentLocationsEvent extends GpsEvent {
  final List<int>? unidadesIds;
  final int? zonaId;
  final bool soloActivas;
  final GpsProviderType? proveedor;

  const LoadCurrentLocationsEvent({
    this.unidadesIds,
    this.zonaId,
    this.soloActivas = false,
    this.proveedor,
  });

  @override
  List<Object?> get props => [unidadesIds, zonaId, soloActivas, proveedor];
}

/// Cargar ubicación de una unidad
class LoadUnitLocationEvent extends GpsEvent {
  final int unidadId;

  const LoadUnitLocationEvent(this.unidadId);

  @override
  List<Object?> get props => [unidadId];
}

/// Refrescar ubicaciones actuales
class RefreshLocationsEvent extends GpsEvent {
  const RefreshLocationsEvent();
}

// ==========================================
// HISTORIAL
// ==========================================

/// Cargar historial de ubicaciones
class LoadLocationHistoryEvent extends GpsEvent {
  final int unidadId;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final GpsProviderType? proveedor;
  final int page;
  final int pageSize;

  const LoadLocationHistoryEvent({
    required this.unidadId,
    this.fechaInicio,
    this.fechaFin,
    this.proveedor,
    this.page = 1,
    this.pageSize = 50,
  });

  @override
  List<Object?> get props => [
    unidadId,
    fechaInicio,
    fechaFin,
    proveedor,
    page,
    pageSize,
  ];
}


class LocationReceivedEvent extends GpsEvent {
  final UnidadTracking unidadTracking;

  const LocationReceivedEvent(this.unidadTracking);

  @override
  List<Object?> get props => [unidadTracking];
}

class ConnectionStatusChangedEvent extends GpsEvent {
  final bool isConnected;

  const ConnectionStatusChangedEvent(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}


/// Cargar historial del día actual
class LoadTodayHistoryEvent extends GpsEvent {
  final int unidadId;

  const LoadTodayHistoryEvent(this.unidadId);

  @override
  List<Object?> get props => [unidadId];
}

// ==========================================
// ESTADÍSTICAS
// ==========================================

/// Cargar estadísticas generales
class LoadTrackingStatsEvent extends GpsEvent {
  const LoadTrackingStatsEvent();
}

/// Cargar estado de una unidad
class LoadUnitStatusEvent extends GpsEvent {
  final int unidadId;

  const LoadUnitStatusEvent(this.unidadId);

  @override
  List<Object?> get props => [unidadId];
}


// ==========================================
// UTILIDADES
// ==========================================

/// Limpiar errores
class ClearGpsErrorEvent extends GpsEvent {
  const ClearGpsErrorEvent();
}

/// Reset completo del state
class ResetGpsStateEvent extends GpsEvent {
  const ResetGpsStateEvent();
}
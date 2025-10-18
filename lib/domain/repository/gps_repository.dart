// =============================================
// GPS Repository Interface - Contrato
// =============================================

import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/models/gps_stats.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Repository interface para operaciones GPS
/// Define el contrato que debe cumplir la implementación
abstract class GpsRepository {
  
  // ==========================================
  // ENVIAR UBICACIÓN
  // ==========================================

  /// Enviar ubicación GPS al servidor (REST - Backup)
  /// 
  /// Usado cuando WebSocket no está disponible
  /// 
  /// **Parámetros:**
  /// - [location]: Ubicación GPS a enviar
  /// 
  /// **Retorna:**
  /// - [Resource<GpsLocation>]: Ubicación guardada con ID asignado
  Future<Resource<GpsLocation>> sendLocation(GpsLocation location);

  /// Enviar múltiples ubicaciones (Batch)
  /// 
  /// Solo para administradores. Útil para sincronizar datos offline.
  /// 
  /// **Parámetros:**
  /// - [locations]: Lista de ubicaciones a enviar
  /// 
  /// **Retorna:**
  /// - [Resource<int>]: Cantidad de ubicaciones guardadas
  Future<Resource<int>> sendLocationBatch(List<GpsLocation> locations);

  // ==========================================
  // CONSULTAR UBICACIONES ACTUALES
  // ==========================================

  /// Obtener ubicación actual de una unidad específica
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<UnidadTracking>]: Unidad con su última ubicación y estado
  Future<Resource<UnidadTracking>> getCurrentLocation(int unidadId);

  /// Obtener ubicaciones actuales de múltiples unidades
  /// 
  /// **Parámetros:**
  /// - [unidadesIds]: Lista de IDs de unidades (opcional)
  /// - [zonaId]: Filtrar por zona (opcional)
  /// - [soloActivas]: Solo unidades con señal reciente (default: false)
  /// - [proveedor]: Filtrar por tipo de proveedor (opcional)
  /// 
  /// **Retorna:**
  /// - [Resource<UnidadesTrackingList>]: Lista de unidades con tracking
  Future<Resource<UnidadesTrackingList>> getCurrentLocations({
    List<int>? unidadesIds,
    int? zonaId,
    bool soloActivas = false,
    GpsProviderType? proveedor,
  });

  /// Obtener última ubicación de una unidad (simple, sin detalles)
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<GpsLocation?>]: Última ubicación o null si no tiene
  Future<Resource<GpsLocation?>> getLastLocation(int unidadId);

  // ==========================================
  // HISTORIAL
  // ==========================================

  /// Obtener historial de ubicaciones (paginado)
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad (opcional)
  /// - [fechaInicio]: Fecha de inicio (opcional)
  /// - [fechaFin]: Fecha de fin (opcional)
  /// - [proveedor]: Filtrar por proveedor (opcional)
  /// - [page]: Número de página (default: 1)
  /// - [pageSize]: Elementos por página (default: 50)
  /// 
  /// **Retorna:**
  /// - [Resource<List<GpsLocation>>]: Lista de ubicaciones históricas
  Future<Resource<List<GpsLocation>>> getLocationHistory({
    int? unidadId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    GpsProviderType? proveedor,
    int page = 1,
    int pageSize = 50,
  });

  // ==========================================
  // ESTADO Y ESTADÍSTICAS
  // ==========================================

  /// Obtener estadísticas generales del sistema GPS
  /// 
  /// **Retorna:**
  /// - [Resource<GpsStats>]: Estadísticas completas
  Future<Resource<GpsStats>> getTrackingStats();

  /// Obtener estado de tracking de una unidad
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<TrackingStatus>]: Estado detallado de tracking
  Future<Resource<TrackingStatus>> getTrackingStatus(int unidadId);

  /// Verificar si una unidad está activa
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<bool>]: true si está activa, false si no
  Future<Resource<bool>> isUnitActive(int unidadId);

  /// Verificar si una unidad tiene GPS vehicular activo
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<bool>]: true si tiene GPS device, false si no
  Future<Resource<bool>> hasActiveGpsDevice(int unidadId);

  /// Obtener lista de unidades inactivas
  /// 
  /// **Parámetros:**
  /// - [minutesThreshold]: Minutos de umbral (default: 60)
  /// 
  /// **Retorna:**
  /// - [Resource<List<int>>]: Lista de IDs de unidades inactivas
  Future<Resource<List<int>>> getInactiveUnits({int minutesThreshold = 60});

  // ==========================================
  // WEBSOCKET (TIEMPO REAL)
  // ==========================================

  /// Conectar al WebSocket para recibir actualizaciones en tiempo real
  /// 
  /// **Parámetros:**
  /// - [token]: Token JWT de autenticación
  /// 
  /// **Retorna:**
  /// - [Resource<void>]: Success si se conectó, Error si falló
  Future<Resource<void>> connectWebSocket(String token);

  /// Desconectar del WebSocket
  Future<void> disconnectWebSocket();

  /// Verificar si está conectado al WebSocket
  bool isWebSocketConnected();

  /// Stream de ubicaciones en tiempo real
  /// 
  /// Emite cada vez que llega una nueva ubicación por WebSocket
  Stream<UnidadTracking> get locationUpdatesStream;

  /// Stream de estado de conexión WebSocket
  /// 
  /// Emite true cuando se conecta, false cuando se desconecta
  Stream<bool> get connectionStatusStream;

  /// Stream de estado de GPS Device
  /// 
  /// Emite cuando un GPS vehicular cambia de estado (activo/inactivo)
  Stream<GpsDeviceStatus> get gpsDeviceStatusStream;

  /// Suscribirse a actualizaciones de tracking
  /// 
  /// **Parámetros:**
  /// - [unidadesIds]: Lista de IDs de unidades (opcional)
  /// - [zonaId]: ID de zona (opcional)
  /// - [all]: Suscribirse a todas las unidades (default: false)
  Future<void> subscribeToTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
  });

  /// Desuscribirse de tracking
  Future<void> unsubscribeFromTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
  });

  /// Suscribirse a una unidad específica
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  Future<void> subscribeToUnit(int unidadId);

  /// Desuscribirse de una unidad específica
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  Future<void> unsubscribeFromUnit(int unidadId);

  /// Solicitar estado actual de una unidad por WebSocket
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  Future<void> requestUnitStatus(int unidadId);

  // ==========================================
  // MANTENIMIENTO (ADMIN)
  // ==========================================

  /// Limpiar ubicaciones antiguas
  /// 
  /// Solo para administradores
  /// 
  /// **Parámetros:**
  /// - [days]: Días de retención (default: 30)
  /// 
  /// **Retorna:**
  /// - [Resource<int>]: Cantidad de ubicaciones eliminadas
  Future<Resource<int>> cleanOldLocations({int days = 30});

  /// Health check del sistema GPS
  /// 
  /// **Retorna:**
  /// - [Resource<Map<String, dynamic>>]: Estado de salud del sistema
  Future<Resource<Map<String, dynamic>>> healthCheck();
}

/// Estado de GPS Device (para el stream)
class GpsDeviceStatus {
  final int unidadId;
  final bool isActive;
  final GpsProviderType proveedor;
  final String? dispositivoId;

  GpsDeviceStatus({
    required this.unidadId,
    required this.isActive,
    required this.proveedor,
    this.dispositivoId,
  });

  factory GpsDeviceStatus.fromJson(Map<String, dynamic> json) {
    return GpsDeviceStatus(
      unidadId: json['unidadId'] as int,
      isActive: json['isActive'] as bool,
      proveedor: GpsProviderType.fromString(json['proveedor'] ?? 'MOBILE_APP'),
      dispositivoId: json['dispositivoId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unidadId': unidadId,
      'isActive': isActive,
      'proveedor': proveedor.value,
      if (dispositivoId != null) 'dispositivoId': dispositivoId,
    };
  }
}
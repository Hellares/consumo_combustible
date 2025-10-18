// =============================================
// Modelo de Estado de Tracking
// =============================================

import 'gps_location.dart';

/// Estado de conexión de una unidad
enum UnitConnectionStatus {
  online('ONLINE'),           // Conectada y enviando datos
  offline('OFFLINE'),         // Sin conexión
  inactive('INACTIVE');       // Inactiva (sin señal > umbral)

  final String value;
  const UnitConnectionStatus(this.value);

  static UnitConnectionStatus fromString(String value) {
    return UnitConnectionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnitConnectionStatus.offline,
    );
  }
}

/// Estado de movimiento de una unidad
enum UnitMovementStatus {
  activo('ACTIVO'),           // En movimiento (velocidad > 5 km/h)
  detenido('DETENIDO'),       // Detenida pero con señal
  inactivo('INACTIVO');       // Sin señal

  final String value;
  const UnitMovementStatus(this.value);

  static UnitMovementStatus fromString(String value) {
    return UnitMovementStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => UnitMovementStatus.inactivo,
    );
  }
}

/// Modelo de estado de tracking de una unidad
class TrackingStatus {
  final int unidadId;
  final bool isOnline;
  final DateTime lastUpdate;
  final GpsProviderType proveedor;
  final double tiempoInactivoMinutos;
  final GpsLocation? ultimaUbicacion;

  TrackingStatus({
    required this.unidadId,
    required this.isOnline,
    required this.lastUpdate,
    required this.proveedor,
    required this.tiempoInactivoMinutos,
    this.ultimaUbicacion,
  });

  /// Factory: desde JSON (API Response)
  factory TrackingStatus.fromJson(Map<String, dynamic> json) {
    return TrackingStatus(
      unidadId: json['unidadId'] as int,
      isOnline: json['isOnline'] as bool,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      proveedor: GpsProviderType.fromString(json['proveedor'] ?? 'MOBILE_APP'),
      tiempoInactivoMinutos: (json['tiempoInactivoMinutos'] as num).toDouble(),
      ultimaUbicacion: json['ultimaUbicacion'] != null
          ? GpsLocation.fromJson(json['ultimaUbicacion'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'unidadId': unidadId,
      'isOnline': isOnline,
      'lastUpdate': lastUpdate.toIso8601String(),
      'proveedor': proveedor.value,
      'tiempoInactivoMinutos': tiempoInactivoMinutos,
      if (ultimaUbicacion != null) 
        'ultimaUbicacion': ultimaUbicacion!.toJson(),
    };
  }

  /// CopyWith
  TrackingStatus copyWith({
    int? unidadId,
    bool? isOnline,
    DateTime? lastUpdate,
    GpsProviderType? proveedor,
    double? tiempoInactivoMinutos,
    GpsLocation? ultimaUbicacion,
  }) {
    return TrackingStatus(
      unidadId: unidadId ?? this.unidadId,
      isOnline: isOnline ?? this.isOnline,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      proveedor: proveedor ?? this.proveedor,
      tiempoInactivoMinutos: tiempoInactivoMinutos ?? this.tiempoInactivoMinutos,
      ultimaUbicacion: ultimaUbicacion ?? this.ultimaUbicacion,
    );
  }

  /// Getters de conveniencia
  UnitConnectionStatus get connectionStatus {
    if (isOnline) return UnitConnectionStatus.online;
    if (tiempoInactivoMinutos > 60) return UnitConnectionStatus.inactive;
    return UnitConnectionStatus.offline;
  }

  UnitMovementStatus get movementStatus {
    if (!isOnline) return UnitMovementStatus.inactivo;
    if (ultimaUbicacion?.isMoving ?? false) return UnitMovementStatus.activo;
    return UnitMovementStatus.detenido;
  }

  bool get hasRecentUpdate => tiempoInactivoMinutos < 5;
  
  bool get isStale => tiempoInactivoMinutos > 10;
  
  bool get hasLocation => ultimaUbicacion != null;

  String get statusDisplayName {
    switch (movementStatus) {
      case UnitMovementStatus.activo:
        return 'En movimiento';
      case UnitMovementStatus.detenido:
        return 'Detenido';
      case UnitMovementStatus.inactivo:
        return 'Sin señal';
    }
  }

  String get connectionDisplayName {
    switch (connectionStatus) {
      case UnitConnectionStatus.online:
        return 'Conectado';
      case UnitConnectionStatus.offline:
        return 'Desconectado';
      case UnitConnectionStatus.inactive:
        return 'Inactivo';
    }
  }

  /// Tiempo transcurrido en formato legible
  String get tiempoTranscurridoDisplay {
    if (tiempoInactivoMinutos < 1) {
      return 'Hace ${(tiempoInactivoMinutos * 60).round()} segundos';
    } else if (tiempoInactivoMinutos < 60) {
      return 'Hace ${tiempoInactivoMinutos.round()} minutos';
    } else {
      final horas = (tiempoInactivoMinutos / 60).floor();
      final minutos = (tiempoInactivoMinutos % 60).round();
      return 'Hace $horas horas${minutos > 0 ? ' y $minutos min' : ''}';
    }
  }

  @override
  String toString() {
    return 'TrackingStatus(unidadId: $unidadId, isOnline: $isOnline, '
        'status: ${movementStatus.value}, '
        'tiempoInactivo: ${tiempoInactivoMinutos.toStringAsFixed(1)} min)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrackingStatus &&
        other.unidadId == unidadId &&
        other.isOnline == isOnline &&
        other.lastUpdate == lastUpdate;
  }

  @override
  int get hashCode {
    return unidadId.hashCode ^ isOnline.hashCode ^ lastUpdate.hashCode;
  }
}
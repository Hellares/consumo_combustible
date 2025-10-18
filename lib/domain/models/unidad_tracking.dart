// =============================================
// Modelo de Unidad con Tracking
// =============================================

import 'gps_location.dart';
import 'tracking_status.dart';

/// Información del conductor
class ConductorInfo {
  final int id;
  final String nombreCompleto;

  ConductorInfo({
    required this.id,
    required this.nombreCompleto,
  });

  factory ConductorInfo.fromJson(Map<String, dynamic> json) {
    return ConductorInfo(
      id: json['id'] as int,
      nombreCompleto: json['nombreCompleto'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
    };
  }
}

/// Modelo completo de unidad con su tracking
class UnidadTracking {
  final int unidadId;
  final String placa;
  final GpsLocation? ultimaUbicacion;
  final int tiempoTranscurrido; // segundos
  final UnitMovementStatus estado;
  final ConductorInfo? conductor;

  UnidadTracking({
    required this.unidadId,
    required this.placa,
    this.ultimaUbicacion,
    required this.tiempoTranscurrido,
    required this.estado,
    this.conductor,
  });

  /// Factory: desde JSON (API Response)
  factory UnidadTracking.fromJson(Map<String, dynamic> json) {
    return UnidadTracking(
      unidadId: json['unidadId'] as int,
      placa: json['placa'] as String,
      ultimaUbicacion: json['ultimaUbicacion'] != null
          ? GpsLocation.fromJson(json['ultimaUbicacion'] as Map<String, dynamic>)
          : null,
      tiempoTranscurrido: json['tiempoTranscurrido'] as int,
      estado: UnitMovementStatus.fromString(json['estado'] ?? 'INACTIVO'),
      conductor: json['conductor'] != null
          ? ConductorInfo.fromJson(json['conductor'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'unidadId': unidadId,
      'placa': placa,
      if (ultimaUbicacion != null) 'ultimaUbicacion': ultimaUbicacion!.toJson(),
      'tiempoTranscurrido': tiempoTranscurrido,
      'estado': estado.value,
      if (conductor != null) 'conductor': conductor!.toJson(),
    };
  }

  /// CopyWith
  UnidadTracking copyWith({
    int? unidadId,
    String? placa,
    GpsLocation? ultimaUbicacion,
    int? tiempoTranscurrido,
    UnitMovementStatus? estado,
    ConductorInfo? conductor,
  }) {
    return UnidadTracking(
      unidadId: unidadId ?? this.unidadId,
      placa: placa ?? this.placa,
      ultimaUbicacion: ultimaUbicacion ?? this.ultimaUbicacion,
      tiempoTranscurrido: tiempoTranscurrido ?? this.tiempoTranscurrido,
      estado: estado ?? this.estado,
      conductor: conductor ?? this.conductor,
    );
  }

  /// Getters de conveniencia
  bool get hasLocation => ultimaUbicacion != null;
  
  /// Una unidad está activa si tiene ubicación reciente (no inactiva)
  /// Esto incluye tanto unidades en movimiento como detenidas
  bool get isActive => estado != UnitMovementStatus.inactivo;
  
  /// Una unidad está en movimiento si su estado es activo
  bool get isMoving => estado == UnitMovementStatus.activo;
  
  bool get isStopped => estado == UnitMovementStatus.detenido;
  
  bool get isInactive => estado == UnitMovementStatus.inactivo;

  bool get hasDriver => conductor != null;

  double get tiempoTranscurridoMinutos => tiempoTranscurrido / 60.0;

  String get estadoDisplayName {
    switch (estado) {
      case UnitMovementStatus.activo:
        return 'En movimiento';
      case UnitMovementStatus.detenido:
        return 'Detenido';
      case UnitMovementStatus.inactivo:
        return 'Sin señal';
    }
  }

  String get tiempoTranscurridoDisplay {
    if (tiempoTranscurrido < 60) {
      return 'Hace $tiempoTranscurrido seg';
    } else if (tiempoTranscurrido < 3600) {
      final minutos = (tiempoTranscurrido / 60).round();
      return 'Hace $minutos min';
    } else {
      final horas = (tiempoTranscurrido / 3600).floor();
      final minutos = ((tiempoTranscurrido % 3600) / 60).round();
      return 'Hace $horas h${minutos > 0 ? ' $minutos min' : ''}';
    }
  }

  @override
  String toString() {
    return 'UnidadTracking(placa: $placa, estado: ${estado.value}, '
        'hasLocation: $hasLocation, conductor: ${conductor?.nombreCompleto})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UnidadTracking &&
        other.unidadId == unidadId &&
        other.placa == placa &&
        other.tiempoTranscurrido == tiempoTranscurrido;
  }

  @override
  int get hashCode {
    return unidadId.hashCode ^ placa.hashCode ^ tiempoTranscurrido.hashCode;
  }
}

/// Lista de unidades con tracking
class UnidadesTrackingList {
  final List<UnidadTracking> data;
  final int total;
  final int activas;
  final int inactivas;

  UnidadesTrackingList({
    required this.data,
    required this.total,
    required this.activas,
    required this.inactivas,
  });

  factory UnidadesTrackingList.fromJson(Map<String, dynamic> json) {
    return UnidadesTrackingList(
      data: (json['data'] as List<dynamic>)
          .map((item) => UnidadTracking.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      activas: json['activas'] as int,
      inactivas: json['inactivas'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
      'activas': activas,
      'inactivas': inactivas,
    };
  }

  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
  
  double get porcentajeActivas => total > 0 ? (activas / total) * 100 : 0;
  double get porcentajeInactivas => total > 0 ? (inactivas / total) * 100 : 0;
}
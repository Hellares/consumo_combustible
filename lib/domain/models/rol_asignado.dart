// lib/domain/models/rol_asignado.dart

class RolAsignado {
  final int usuarioId;
  final DateTime fechaAsignacion;
  final DateTime? fechaRevocacion;
  final bool activo;
  final int asignadoPorId;
  final RolInfo rol;

  RolAsignado({
    required this.usuarioId,
    required this.fechaAsignacion,
    this.fechaRevocacion,
    required this.activo,
    required this.asignadoPorId,
    required this.rol,
  });

  /// Crear desde JSON (respuesta del backend)
  factory RolAsignado.fromJson(Map<String, dynamic> json) {
    return RolAsignado(
      usuarioId: json['usuarioId'] as int,
      fechaAsignacion: DateTime.parse(json['fechaAsignacion'] as String),
      fechaRevocacion: json['fechaRevocacion'] != null
          ? DateTime.parse(json['fechaRevocacion'] as String)
          : null,
      activo: json['activo'] as bool,
      asignadoPorId: json['asignadoPorId'] as int,
      rol: RolInfo.fromJson(json['rol'] as Map<String, dynamic>),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'fechaAsignacion': fechaAsignacion.toIso8601String(),
      'fechaRevocacion': fechaRevocacion?.toIso8601String(),
      'activo': activo,
      'asignadoPorId': asignadoPorId,
      'rol': rol.toJson(),
    };
  }

  @override
  String toString() {
    return 'RolAsignado(usuarioId: $usuarioId, rol: ${rol.nombre}, activo: $activo)';
  }
}

/// Información básica del rol dentro de RolAsignado
class RolInfo {
  final int id;
  final String nombre;
  final String? descripcion;

  RolInfo({
    required this.id,
    required this.nombre,
    this.descripcion,
  });

  factory RolInfo.fromJson(Map<String, dynamic> json) {
    return RolInfo(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  @override
  String toString() => 'RolInfo(id: $id, nombre: $nombre)';
}
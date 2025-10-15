// lib/domain/models/asignar_rol_request.dart

class AsignarRolRequest {
  final int rolId;
  final int asignadoPorId;

  AsignarRolRequest({
    required this.rolId,
    required this.asignadoPorId,
  });

  // Convertir a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'rolId': rolId,
      'asignadoPorId': asignadoPorId,
    };
  }

  // Crear desde JSON (por si lo necesitas)
  factory AsignarRolRequest.fromJson(Map<String, dynamic> json) {
    return AsignarRolRequest(
      rolId: json['rolId'] as int,
      asignadoPorId: json['asignadoPorId'] as int,
    );
  }

  @override
  String toString() {
    return 'AsignarRolRequest(rolId: $rolId, asignadoPorId: $asignadoPorId)';
  }
}
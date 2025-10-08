// lib/domain/models/create_licencia_request.dart

class CreateLicenciaRequest {
  final int usuarioId;
  final String numeroLicencia;
  final String categoria;
  final String fechaEmision;
  final String fechaExpiracion;

  CreateLicenciaRequest({
    required this.usuarioId,
    required this.numeroLicencia,
    required this.categoria,
    required this.fechaEmision,
    required this.fechaExpiracion,
  });

  Map<String, dynamic> toJson() {
    return {
      'usuarioId': usuarioId,
      'numeroLicencia': numeroLicencia,
      'categoria': categoria,
      'fechaEmision': fechaEmision,
      'fechaExpiracion': fechaExpiracion,
    };
  }
}
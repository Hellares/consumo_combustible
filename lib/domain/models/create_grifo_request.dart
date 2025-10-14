class CreateGrifoRequest {
  final int sedeId;
  final String nombre;
  final String codigo;
  final String? direccion;
  final String? telefono;
  final String? horarioApertura;
  final String? horarioCierre;
  final bool activo;

  CreateGrifoRequest({
    required this.sedeId,
    required this.nombre,
    required this.codigo,
    this.direccion,
    this.telefono,
    this.horarioApertura,
    this.horarioCierre,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'sedeId': sedeId,
      'nombre': nombre,
      'codigo': codigo,
      if (direccion != null && direccion!.isNotEmpty) 'direccion': direccion,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
      if (horarioApertura != null && horarioApertura!.isNotEmpty) 
        'horarioApertura': horarioApertura,
      if (horarioCierre != null && horarioCierre!.isNotEmpty) 
        'horarioCierre': horarioCierre,
      'activo': activo,
    };
  }
}
class CreateSedeRequest {
  final int zonaId;
  final String nombre;
  final String codigo;
  final String? direccion;
  final String? telefono;
  final bool activo;

  CreateSedeRequest({
    required this.zonaId,
    required this.nombre,
    required this.codigo,
    this.direccion,
    this.telefono,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'zonaId': zonaId,
      'nombre': nombre,
      'codigo': codigo,
      if (direccion != null && direccion!.isNotEmpty) 'direccion': direccion,
      if (telefono != null && telefono!.isNotEmpty) 'telefono': telefono,
      'activo': activo,
    };
  }
}
class CreateZonaRequest {
  final String nombre;
  final String codigo;
  final String descripcion;
  final bool activo;

  CreateZonaRequest({
    required this.nombre,
    required this.codigo,
    required this.descripcion,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
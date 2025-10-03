class Zona {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final bool activo;
  final int sedesCount;
  final int unidadesCount;

  Zona({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.activo,
    required this.sedesCount,
    required this.unidadesCount,
  });

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
      sedesCount: json['sedesCount'] ?? 0,
      unidadesCount: json['unidadesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'descripcion': descripcion,
      'activo': activo,
      'sedesCount': sedesCount,
      'unidadesCount': unidadesCount,
    };
  }
}
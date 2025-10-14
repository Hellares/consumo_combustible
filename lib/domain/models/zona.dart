class Zona {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final bool activo;
  final DateTime? createdAt;  // ⭐ NUEVO
  final DateTime? updatedAt;  // ⭐ NUEVO
  final int sedesCount;
  final int unidadesCount;

  Zona({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.activo,
    this.createdAt,  // ⭐ NUEVO
    this.updatedAt,  // ⭐ NUEVO
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
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,  // ⭐ NUEVO
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,  // ⭐ NUEVO
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
      'createdAt': createdAt?.toIso8601String(),  // ⭐ NUEVO
      'updatedAt': updatedAt?.toIso8601String(),  // ⭐ NUEVO
      'sedesCount': sedesCount,
      'unidadesCount': unidadesCount,
    };
  }
}
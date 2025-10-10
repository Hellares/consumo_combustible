// lib/domain/models/tipo_archivo.dart

class TipoArchivo {
  final int id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final String categoria; // IMAGEN, COMPROBANTE, DOCUMENTO
  final bool requerido;
  final int orden;
  final bool activo;
  final DateTime createdAt;

  TipoArchivo({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.requerido,
    required this.orden,
    required this.activo,
    required this.createdAt,
  });

  factory TipoArchivo.fromJson(Map<String, dynamic> json) {
    return TipoArchivo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      requerido: json['requerido'] as bool,
      orden: json['orden'] as int,
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'requerido': requerido,
      'orden': orden,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Getters de conveniencia para categorías
  bool get esImagen => categoria == 'IMAGEN';
  bool get esComprobante => categoria == 'COMPROBANTE';
  bool get esDocumento => categoria == 'DOCUMENTO';

  // Iconos según categoría
  String get iconoCategoria {
    switch (categoria) {
      case 'IMAGEN':
        return '📷';
      case 'COMPROBANTE':
        return '🧾';
      case 'DOCUMENTO':
        return '📄';
      default:
        return '📎';
    }
  }

  // Color según categoría (para UI)
  int get colorCategoria {
    switch (categoria) {
      case 'IMAGEN':
        return 0xFF2196F3; // Azul
      case 'COMPROBANTE':
        return 0xFF4CAF50; // Verde
      case 'DOCUMENTO':
        return 0xFFFF9800; // Naranja
      default:
        return 0xFF9E9E9E; // Gris
    }
  }

  // Badge de requerido
  String get badgeRequerido => requerido ? '⚠️ Requerido' : 'Opcional';

  @override
  String toString() {
    return 'TipoArchivo(id: $id, codigo: $codigo, nombre: $nombre, categoria: $categoria, requerido: $requerido)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TipoArchivo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
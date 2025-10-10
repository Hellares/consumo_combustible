// lib/domain/models/archivo_ticket.dart

class ArchivoTicket {
  final int id;
  final int ticketId;
  final String nombreArchivo;
  final String nombreOriginal;
  final String url;
  final String? urlThumbnail;
  final String rutaAlmacenamiento;
  final String tipoMime;
  final int tamanoBytes;
  final String extension;
  final Map<String, dynamic>? metadatos;
  final String? descripcion;
  final int orden;
  final bool esPrincipal;
  final TipoArchivoInfo tipoArchivo;
  final SubidoPorInfo? subidoPor;
  final DateTime fechaSubida;
  final bool activo;
  final DateTime createdAt;

  ArchivoTicket({
    required this.id,
    required this.ticketId,
    required this.nombreArchivo,
    required this.nombreOriginal,
    required this.url,
    this.urlThumbnail,
    required this.rutaAlmacenamiento,
    required this.tipoMime,
    required this.tamanoBytes,
    required this.extension,
    this.metadatos,
    this.descripcion,
    required this.orden,
    required this.esPrincipal,
    required this.tipoArchivo,
    this.subidoPor,
    required this.fechaSubida,
    required this.activo,
    required this.createdAt,
  });

  factory ArchivoTicket.fromJson(Map<String, dynamic> json) {
    return ArchivoTicket(
      id: json['id'] as int,
      ticketId: json['ticketId'] as int,
      nombreArchivo: json['nombreArchivo'] as String,
      nombreOriginal: json['nombreOriginal'] as String,
      url: json['url'] as String,
      urlThumbnail: json['urlThumbnail'] as String?,
      rutaAlmacenamiento: json['rutaAlmacenamiento'] as String,
      tipoMime: json['tipoMime'] as String,
      tamanoBytes: json['tamanoBytes'] as int,
      extension: json['extension'] as String,
      metadatos: json['metadatos'] as Map<String, dynamic>?,
      descripcion: json['descripcion'] as String?,
      orden: json['orden'] as int,
      esPrincipal: json['esPrincipal'] as bool,
      tipoArchivo: TipoArchivoInfo.fromJson(json['tipoArchivo'] as Map<String, dynamic>),
      subidoPor: json['subidoPor'] != null 
          ? SubidoPorInfo.fromJson(json['subidoPor'] as Map<String, dynamic>)
          : null,
      fechaSubida: DateTime.parse(json['fechaSubida'] as String),
      activo: json['activo'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticketId': ticketId,
      'nombreArchivo': nombreArchivo,
      'nombreOriginal': nombreOriginal,
      'url': url,
      'urlThumbnail': urlThumbnail,
      'rutaAlmacenamiento': rutaAlmacenamiento,
      'tipoMime': tipoMime,
      'tamanoBytes': tamanoBytes,
      'extension': extension,
      'metadatos': metadatos,
      'descripcion': descripcion,
      'orden': orden,
      'esPrincipal': esPrincipal,
      'tipoArchivo': tipoArchivo.toJson(),
      'subidoPor': subidoPor?.toJson(),
      'fechaSubida': fechaSubida.toIso8601String(),
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Getters útiles
  bool get esImagen => tipoMime.startsWith('image/');
  bool get esPdf => tipoMime == 'application/pdf';

  String get tamanoLegible {
    if (tamanoBytes < 1024) return '$tamanoBytes B';
    if (tamanoBytes < 1024 * 1024) {
      return '${(tamanoBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(tamanoBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get urlParaVisualizacion => urlThumbnail ?? url;

  // Dimensiones de la imagen (si aplica)
  int? get width => metadatos?['width'] as int?;
  int? get height => metadatos?['height'] as int?;
  String? get format => metadatos?['format'] as String?;
}

// Clase para información del tipo de archivo
class TipoArchivoInfo {
  final int id;
  final String codigo;
  final String nombre;
  final String descripcion;
  final String categoria;
  final bool requerido;
  final int orden;

  TipoArchivoInfo({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.requerido,
    required this.orden,
  });

  factory TipoArchivoInfo.fromJson(Map<String, dynamic> json) {
    return TipoArchivoInfo(
      id: json['id'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      categoria: json['categoria'] as String,
      requerido: json['requerido'] as bool,
      orden: json['orden'] as int,
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
}

// Clase para información de quien subió el archivo
class SubidoPorInfo {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String codigoEmpleado;

  SubidoPorInfo({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.codigoEmpleado,
  });

  factory SubidoPorInfo.fromJson(Map<String, dynamic> json) {
    return SubidoPorInfo(
      id: json['id'] as int,
      nombres: json['nombres'] as String,
      apellidos: json['apellidos'] as String,
      dni: json['dni'] as String,
      codigoEmpleado: json['codigoEmpleado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'dni': dni,
      'codigoEmpleado': codigoEmpleado,
    };
  }

  String get nombreCompleto => '$nombres $apellidos';
}
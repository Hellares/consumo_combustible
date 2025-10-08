// lib/domain/models/licencia_conducir.dart

class LicenciaConducir {
  final int id;
  final int usuarioId;
  final String numeroLicencia;
  final String categoria;
  final DateTime fechaEmision;
  final DateTime fechaExpiracion;
  final String? entidadEmisora;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UsuarioLicencia usuario;
  final int diasRestantes;
  final bool estaVencida;
  final bool proximaVencimiento;
  final String estadoVigencia;

  LicenciaConducir({
    required this.id,
    required this.usuarioId,
    required this.numeroLicencia,
    required this.categoria,
    required this.fechaEmision,
    required this.fechaExpiracion,
    this.entidadEmisora,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
    required this.usuario,
    required this.diasRestantes,
    required this.estaVencida,
    required this.proximaVencimiento,
    required this.estadoVigencia,
  });

  factory LicenciaConducir.fromJson(Map<String, dynamic> json) {
    return LicenciaConducir(
      id: json['id'],
      usuarioId: json['usuarioId'],
      numeroLicencia: json['numeroLicencia'],
      categoria: json['categoria'],
      fechaEmision: DateTime.parse(json['fechaEmision']),
      fechaExpiracion: DateTime.parse(json['fechaExpiracion']),
      entidadEmisora: json['entidadEmisora'],
      activo: json['activo'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      usuario: UsuarioLicencia.fromJson(json['usuario']),
      diasRestantes: json['diasRestantes'],
      estaVencida: json['estaVencida'],
      proximaVencimiento: json['proximaVencimiento'],
      estadoVigencia: json['estadoVigencia'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'numeroLicencia': numeroLicencia,
      'categoria': categoria,
      'fechaEmision': fechaEmision.toIso8601String(),
      'fechaExpiracion': fechaExpiracion.toIso8601String(),
      'entidadEmisora': entidadEmisora,
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'usuario': usuario.toJson(),
      'diasRestantes': diasRestantes,
      'estaVencida': estaVencida,
      'proximaVencimiento': proximaVencimiento,
      'estadoVigencia': estadoVigencia,
    };
  }

  // Helpers útiles
  String get nombreCompleto => '${usuario.nombres} ${usuario.apellidos}';
  
  bool get esVigente => estadoVigencia == 'VIGENTE';
  
  bool get requiereAtencion => estaVencida || proximaVencimiento;

  String get estadoColor {
    switch (estadoVigencia) {
      case 'VIGENTE':
        return 'green';
      case 'PROXIMA_VENCIMIENTO':
        return 'orange';
      case 'VENCIDA':
        return 'red';
      default:
        return 'grey';
    }
  }
}

class UsuarioLicencia {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String codigoEmpleado;

  UsuarioLicencia({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.codigoEmpleado,
  });

  factory UsuarioLicencia.fromJson(Map<String, dynamic> json) {
    return UsuarioLicencia(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      dni: json['dni'],
      codigoEmpleado: json['codigoEmpleado'],
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

// Modelo para respuesta paginada
class LicenciasResponse {
  final List<LicenciaConducir> data;
  final MetaData meta;

  LicenciasResponse({
    required this.data,
    required this.meta,
  });

  factory LicenciasResponse.fromJson(Map<String, dynamic> json) {
    final responseData = json['data'];
    
    return LicenciasResponse(
      data: (responseData['data'] as List)
          .map((e) => LicenciaConducir.fromJson(e))
          .toList(),
      meta: MetaData.fromJson(responseData['meta']),
    );
  }
}

class MetaData {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final int offset;
  final int limit;
  final int? nextOffset;
  final int? prevOffset;
  final bool hasNext;
  final bool hasPrevious;

  MetaData({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.offset,
    required this.limit,
    this.nextOffset,
    this.prevOffset,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory MetaData.fromJson(Map<String, dynamic> json) {
    return MetaData(
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      offset: json['offset'],
      limit: json['limit'],
      nextOffset: json['nextOffset'],
      prevOffset: json['prevOffset'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
    );
  }
}
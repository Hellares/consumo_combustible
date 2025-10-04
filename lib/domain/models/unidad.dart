// lib/domain/models/unidad.dart

class Unidad {
  final int id;
  final String placa;
  final int conductorOperadorId;
  final String operacion;
  final String marca;
  final String modelo;
  final int anio;
  final String nroVin;
  final String nroMotor;
  final int zonaOperacionId;
  final double capacidadTanque;
  final String tipoCombustible;
  final double odometroInicial;
  final double horometroInicial;
  final String fechaAdquisicion;
  final String estado;
  final bool activo;
  final ConductorOperador conductorOperador;
  final ZonaOperacion zonaOperacion;
  final int abastecimientosCount;
  final int mantenimientosCount;
  final int fallasCount;
  final int antiguedadAnios;
  final bool puedeOperar;

  Unidad({
    required this.id,
    required this.placa,
    required this.conductorOperadorId,
    required this.operacion,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.nroVin,
    required this.nroMotor,
    required this.zonaOperacionId,
    required this.capacidadTanque,
    required this.tipoCombustible,
    required this.odometroInicial,
    required this.horometroInicial,
    required this.fechaAdquisicion,
    required this.estado,
    required this.activo,
    required this.conductorOperador,
    required this.zonaOperacion,
    required this.abastecimientosCount,
    required this.mantenimientosCount,
    required this.fallasCount,
    required this.antiguedadAnios,
    required this.puedeOperar,
  });

  factory Unidad.fromJson(Map<String, dynamic> json) {
    return Unidad(
      id: json['id'] ?? 0,
      placa: json['placa'] ?? '',
      conductorOperadorId: json['conductorOperadorId'] ?? 0,
      operacion: json['operacion'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'] ?? 0,
      nroVin: json['nroVin'] ?? '',
      nroMotor: json['nroMotor'] ?? '',
      zonaOperacionId: json['zonaOperacionId'] ?? 0,
      capacidadTanque: (json['capacidadTanque'] ?? 0).toDouble(),
      tipoCombustible: json['tipoCombustible'] ?? '',
      odometroInicial: (json['odometroInicial'] ?? 0).toDouble(),
      horometroInicial: (json['horometroInicial'] ?? 0).toDouble(),
      fechaAdquisicion: json['fechaAdquisicion'] ?? '',
      estado: json['estado'] ?? '',
      activo: json['activo'] ?? true,
      conductorOperador: ConductorOperador.fromJson(
        json['conductorOperador'] ?? {},
      ),
      zonaOperacion: ZonaOperacion.fromJson(
        json['zonaOperacion'] ?? {},
      ),
      abastecimientosCount: json['abastecimientosCount'] ?? 0,
      mantenimientosCount: json['mantenimientosCount'] ?? 0,
      fallasCount: json['fallasCount'] ?? 0,
      antiguedadAnios: json['antiguedadAnios'] ?? 0,
      puedeOperar: json['puedeOperar'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'conductorOperadorId': conductorOperadorId,
      'operacion': operacion,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'nroVin': nroVin,
      'nroMotor': nroMotor,
      'zonaOperacionId': zonaOperacionId,
      'capacidadTanque': capacidadTanque,
      'tipoCombustible': tipoCombustible,
      'odometroInicial': odometroInicial,
      'horometroInicial': horometroInicial,
      'fechaAdquisicion': fechaAdquisicion,
      'estado': estado,
      'activo': activo,
      'conductorOperador': conductorOperador.toJson(),
      'zonaOperacion': zonaOperacion.toJson(),
      'abastecimientosCount': abastecimientosCount,
      'mantenimientosCount': mantenimientosCount,
      'fallasCount': fallasCount,
      'antiguedadAnios': antiguedadAnios,
      'puedeOperar': puedeOperar,
    };
  }

  // Método helper para mostrar en dropdown
  String get displayName => '$placa - $marca $modelo';
}

class ConductorOperador {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String codigoEmpleado;

  ConductorOperador({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.codigoEmpleado,
  });

  factory ConductorOperador.fromJson(Map<String, dynamic> json) {
    return ConductorOperador(
      id: json['id'] ?? 0,
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      dni: json['dni'] ?? '',
      codigoEmpleado: json['codigoEmpleado'] ?? '',
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

class ZonaOperacion {
  final int id;
  final String nombre;
  final String codigo;

  ZonaOperacion({
    required this.id,
    required this.nombre,
    required this.codigo,
  });

  factory ZonaOperacion.fromJson(Map<String, dynamic> json) {
    return ZonaOperacion(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
    };
  }
}

// Modelo para la respuesta paginada
class UnidadesResponse {
  final List<Unidad> data;
  final MetaData meta;

  UnidadesResponse({
    required this.data,
    required this.meta,
  });

  factory UnidadesResponse.fromJson(Map<String, dynamic> json) {
    return UnidadesResponse(
      data: (json['data'] as List?)
              ?.map((item) => Unidad.fromJson(item))
              .toList() ??
          [],
      meta: MetaData.fromJson(json['meta'] ?? {}),
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
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      offset: json['offset'] ?? 0,
      limit: json['limit'] ?? 10,
      nextOffset: json['nextOffset'],
      prevOffset: json['prevOffset'],
      hasNext: json['hasNext'] ?? false,
      hasPrevious: json['hasPrevious'] ?? false,
    );
  }
}
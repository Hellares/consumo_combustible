// lib/domain/models/reporte_response.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';

/// Modelo para la respuesta del endpoint /reportes/datos
/// Cuando el backend devuelve JSON en lugar de un archivo
class ReporteResponse {
  final bool success;
  final TipoReporte tipoReporte;
  final FiltrosReporteInfo filtros;
  final int totalRegistros;
  final DateTime fechaConsulta;
  final List<Map<String, dynamic>> datos;

  ReporteResponse({
    required this.success,
    required this.tipoReporte,
    required this.filtros,
    required this.totalRegistros,
    required this.fechaConsulta,
    required this.datos,
  });

  factory ReporteResponse.fromJson(Map<String, dynamic> json) {
    return ReporteResponse(
      success: json['success'] ?? false,
      tipoReporte: _parseTipoReporte(json['tipoReporte']),
      filtros: FiltrosReporteInfo.fromJson(json['filtros'] ?? {}),
      totalRegistros: json['totalRegistros'] ?? 0,
      fechaConsulta: json['fechaConsulta'] != null
          ? DateTime.parse(json['fechaConsulta'])
          : DateTime.now(),
      datos: (json['datos'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  /// Parser seguro para TipoReporte
  static TipoReporte _parseTipoReporte(dynamic value) {
    if (value == null) return TipoReporte.abastecimientos;
    
    final String stringValue = value.toString().toLowerCase();
    
    return TipoReporte.values.firstWhere(
      (e) => e.value == stringValue,
      orElse: () => TipoReporte.abastecimientos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'tipoReporte': tipoReporte.value,
      'filtros': filtros.toJson(),
      'totalRegistros': totalRegistros,
      'fechaConsulta': fechaConsulta.toIso8601String(),
      'datos': datos,
    };
  }

  @override
  String toString() {
    return 'ReporteResponse('
        'success: $success, '
        'tipo: $tipoReporte, '
        'registros: $totalRegistros'
        ')';
  }
}

/// Información de los filtros aplicados en la respuesta
class FiltrosReporteInfo {
  final String? fechaInicio;
  final String? fechaFin;
  final int? zonaId;
  final int? sedeId;
  final int? grifoId;
  final int? unidadId;
  final String? placa;
  final int? conductorId;
  final int? rutaId;
  final String? estadoTicket;

  FiltrosReporteInfo({
    this.fechaInicio,
    this.fechaFin,
    this.zonaId,
    this.sedeId,
    this.grifoId,
    this.unidadId,
    this.placa,
    this.conductorId,
    this.rutaId,
    this.estadoTicket,
  });

  factory FiltrosReporteInfo.fromJson(Map<String, dynamic> json) {
    return FiltrosReporteInfo(
      fechaInicio: json['fechaInicio'] as String?,
      fechaFin: json['fechaFin'] as String?,
      zonaId: json['zonaId'] as int?,
      sedeId: json['sedeId'] as int?,
      grifoId: json['grifoId'] as int?,
      unidadId: json['unidadId'] as int?,
      placa: json['placa'] as String?,
      conductorId: json['conductorId'] as int?,
      rutaId: json['rutaId'] as int?,
      estadoTicket: json['estadoTicket'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fechaInicio': fechaInicio,
      'fechaFin': fechaFin,
      'zonaId': zonaId,
      'sedeId': sedeId,
      'grifoId': grifoId,
      'unidadId': unidadId,
      'placa': placa,
      'conductorId': conductorId,
      'rutaId': rutaId,
      'estadoTicket': estadoTicket,
    };
  }

  @override
  String toString() {
    final filtros = <String>[];
    if (fechaInicio != null) filtros.add('desde: $fechaInicio');
    if (fechaFin != null) filtros.add('hasta: $fechaFin');
    if (zonaId != null) filtros.add('zona: $zonaId');
    if (placa != null) filtros.add('placa: $placa');
    
    return 'FiltrosReporteInfo(${filtros.join(", ")})';
  }
}

/// Modelo para la respuesta del endpoint /reportes/resumen
class ResumenReporteResponse {
  final bool success;
  final ResumenData resumen;
  final List<TipoReporteInfo> tiposReporteDisponibles;
  final List<FormatoInfo> formatosDisponibles;

  ResumenReporteResponse({
    required this.success,
    required this.resumen,
    required this.tiposReporteDisponibles,
    required this.formatosDisponibles,
  });

  factory ResumenReporteResponse.fromJson(Map<String, dynamic> json) {
    return ResumenReporteResponse(
      success: json['success'] ?? false,
      resumen: ResumenData.fromJson(json['resumen'] ?? {}),
      tiposReporteDisponibles: (json['tiposReporteDisponibles'] as List?)
              ?.map((e) => TipoReporteInfo.fromJson(e))
              .toList() ??
          [],
      formatosDisponibles: (json['formatosDisponibles'] as List?)
              ?.map((e) => FormatoInfo.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Datos del resumen general
class ResumenData {
  final int totalAbastecimientos;
  final int totalUnidades;
  final int totalGrifos;
  final DateTime? fechaPrimerRegistro;
  final DateTime? fechaUltimoRegistro;

  ResumenData({
    required this.totalAbastecimientos,
    required this.totalUnidades,
    required this.totalGrifos,
    this.fechaPrimerRegistro,
    this.fechaUltimoRegistro,
  });

  factory ResumenData.fromJson(Map<String, dynamic> json) {
    return ResumenData(
      totalAbastecimientos: json['totalAbastecimientos'] ?? 0,
      totalUnidades: json['totalUnidades'] ?? 0,
      totalGrifos: json['totalGrifos'] ?? 0,
      fechaPrimerRegistro: json['fechaPrimerRegistro'] != null
          ? DateTime.parse(json['fechaPrimerRegistro'])
          : null,
      fechaUltimoRegistro: json['fechaUltimoRegistro'] != null
          ? DateTime.parse(json['fechaUltimoRegistro'])
          : null,
    );
  }

  @override
  String toString() {
    return 'ResumenData('
        'abastecimientos: $totalAbastecimientos, '
        'unidades: $totalUnidades, '
        'grifos: $totalGrifos'
        ')';
  }
}

/// Información de tipos de reporte disponibles
class TipoReporteInfo {
  final String tipo;
  final String nombre;
  final String descripcion;

  TipoReporteInfo({
    required this.tipo,
    required this.nombre,
    required this.descripcion,
  });

  factory TipoReporteInfo.fromJson(Map<String, dynamic> json) {
    return TipoReporteInfo(
      tipo: json['tipo'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  @override
  String toString() => 'TipoReporteInfo($nombre)';
}

/// Información de formatos disponibles
class FormatoInfo {
  final String formato;
  final String extension;
  final String descripcion;

  FormatoInfo({
    required this.formato,
    required this.extension,
    required this.descripcion,
  });

  factory FormatoInfo.fromJson(Map<String, dynamic> json) {
    return FormatoInfo(
      formato: json['formato'] ?? '',
      extension: json['extension'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  @override
  String toString() => 'FormatoInfo($extension - $descripcion)';
}

/// Modelo para respuesta de descarga de archivo
/// No contiene datos, solo metadata del proceso
class DescargaArchivoResponse {
  final bool success;
  final String mensaje;
  final String? rutaArchivo; // Ruta local donde se guardó
  final String nombreArchivo;
  final int? tamanioBytes;
  final FormatoExportacion formato;

  DescargaArchivoResponse({
    required this.success,
    required this.mensaje,
    this.rutaArchivo,
    required this.nombreArchivo,
    this.tamanioBytes,
    required this.formato,
  });

  /// Constructor para descarga exitosa
  factory DescargaArchivoResponse.exitosa({
    required String rutaArchivo,
    required String nombreArchivo,
    required int tamanioBytes,
    required FormatoExportacion formato,
  }) {
    return DescargaArchivoResponse(
      success: true,
      mensaje: 'Archivo descargado exitosamente',
      rutaArchivo: rutaArchivo,
      nombreArchivo: nombreArchivo,
      tamanioBytes: tamanioBytes,
      formato: formato,
    );
  }

  /// Constructor para error en descarga
  factory DescargaArchivoResponse.error({
    required String mensaje,
    required String nombreArchivo,
    required FormatoExportacion formato,
  }) {
    return DescargaArchivoResponse(
      success: false,
      mensaje: mensaje,
      nombreArchivo: nombreArchivo,
      formato: formato,
    );
  }

  /// Obtener tamaño formateado legible
  String get tamanioFormateado {
    if (tamanioBytes == null) return 'Desconocido';
    
    if (tamanioBytes! < 1024) {
      return '$tamanioBytes B';
    } else if (tamanioBytes! < 1024 * 1024) {
      return '${(tamanioBytes! / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(tamanioBytes! / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  @override
  String toString() {
    return 'DescargaArchivoResponse('
        'success: $success, '
        'archivo: $nombreArchivo, '
        'tamaño: $tamanioFormateado'
        ')';
  }
}
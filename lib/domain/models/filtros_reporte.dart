// lib/domain/models/filtros_reporte.dart

/// Enums para los tipos de reporte
enum TipoReporte {
  abastecimientos('abastecimientos'),
  consumoPorUnidad('consumo_por_unidad'),
  estadisticasGrifo('estadisticas_grifo'),
  rendimiento('rendimiento');

  final String value;
  const TipoReporte(this.value);

  @override
  String toString() => value;
}

/// Enums para los formatos de exportación
enum FormatoExportacion {
  excel('excel'),
  csv('csv'),
  json('json');

  final String value;
  const FormatoExportacion(this.value);

  @override
  String toString() => value;
}

/// Modelo de filtros para reportes
/// Sigue el mismo patrón de tu arquitectura actual
class FiltrosReporte {
  // === FILTROS PRINCIPALES ===
  final TipoReporte tipoReporte;
  final FormatoExportacion formato;
  
  // === FILTROS DE FECHA ===
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  
  // === FILTROS DE UBICACIÓN ===
  final int? zonaId;
  final int? sedeId;
  final int? grifoId;
  
  // === FILTROS DE UNIDAD Y CONDUCTOR ===
  final int? unidadId;
  final String? placa;
  final int? conductorId;
  
  // === FILTROS DE RUTA Y TURNO ===
  final int? rutaId;
  final int? turnoId;
  
  // === FILTROS DE ESTADO ===
  final String? estadoTicket;
  final String? tipoCombustible;
  final bool? soloCompletados;

  const FiltrosReporte({
    this.tipoReporte = TipoReporte.abastecimientos,
    this.formato = FormatoExportacion.excel,
    this.fechaInicio,
    this.fechaFin,
    this.zonaId,
    this.sedeId,
    this.grifoId,
    this.unidadId,
    this.placa,
    this.conductorId,
    this.rutaId,
    this.turnoId,
    this.estadoTicket,
    this.tipoCombustible,
    this.soloCompletados,
  });

  /// Convertir filtros a query parameters para Dio
  /// Ejemplo: {"formato": "excel", "fechaInicio": "2025-01-01"}
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    // Formato y tipo (siempre se envían)
    params['formato'] = formato.value;
    params['tipoReporte'] = tipoReporte.value;

    // Fechas (formato ISO 8601 para el backend)
    if (fechaInicio != null) {
      params['fechaInicio'] = _formatDate(fechaInicio!);
    }
    if (fechaFin != null) {
      params['fechaFin'] = _formatDate(fechaFin!);
    }

    // IDs (solo si tienen valor)
    if (zonaId != null) params['zonaId'] = zonaId;
    if (sedeId != null) params['sedeId'] = sedeId;
    if (grifoId != null) params['grifoId'] = grifoId;
    if (unidadId != null) params['unidadId'] = unidadId;
    if (conductorId != null) params['conductorId'] = conductorId;
    if (rutaId != null) params['rutaId'] = rutaId;
    if (turnoId != null) params['turnoId'] = turnoId;

    // Strings
    if (placa != null && placa!.isNotEmpty) params['placa'] = placa;
    if (estadoTicket != null && estadoTicket!.isNotEmpty) {
      params['estadoTicket'] = estadoTicket;
    }
    if (tipoCombustible != null && tipoCombustible!.isNotEmpty) {
      params['tipoCombustible'] = tipoCombustible;
    }

    // Booleanos
    if (soloCompletados != null) {
      params['soloCompletados'] = soloCompletados;
    }

    return params;
  }

  /// Formatear fecha a YYYY-MM-DD (formato esperado por el backend)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// CopyWith para facilitar la modificación de filtros
  FiltrosReporte copyWith({
    TipoReporte? tipoReporte,
    FormatoExportacion? formato,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? zonaId,
    int? sedeId,
    int? grifoId,
    int? unidadId,
    String? placa,
    int? conductorId,
    int? rutaId,
    int? turnoId,
    String? estadoTicket,
    String? tipoCombustible,
    bool? soloCompletados,
  }) {
    return FiltrosReporte(
      tipoReporte: tipoReporte ?? this.tipoReporte,
      formato: formato ?? this.formato,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      zonaId: zonaId ?? this.zonaId,
      sedeId: sedeId ?? this.sedeId,
      grifoId: grifoId ?? this.grifoId,
      unidadId: unidadId ?? this.unidadId,
      placa: placa ?? this.placa,
      conductorId: conductorId ?? this.conductorId,
      rutaId: rutaId ?? this.rutaId,
      turnoId: turnoId ?? this.turnoId,
      estadoTicket: estadoTicket ?? this.estadoTicket,
      tipoCombustible: tipoCombustible ?? this.tipoCombustible,
      soloCompletados: soloCompletados ?? this.soloCompletados,
    );
  }

  /// Limpiar filtros (solo mantener tipo y formato)
  FiltrosReporte limpiar() {
    return FiltrosReporte(
      tipoReporte: tipoReporte,
      formato: formato,
    );
  }

  /// Validar si hay filtros aplicados (útil para UI)
  bool tieneFiltros() {
    return fechaInicio != null ||
        fechaFin != null ||
        zonaId != null ||
        sedeId != null ||
        grifoId != null ||
        unidadId != null ||
        placa != null ||
        conductorId != null ||
        rutaId != null ||
        turnoId != null ||
        estadoTicket != null ||
        tipoCombustible != null ||
        soloCompletados != null;
  }

  /// Obtener descripción legible de los filtros aplicados
  String obtenerDescripcionFiltros() {
    final filtros = <String>[];

    if (fechaInicio != null) {
      filtros.add('Desde: ${_formatDate(fechaInicio!)}');
    }
    if (fechaFin != null) {
      filtros.add('Hasta: ${_formatDate(fechaFin!)}');
    }
    if (zonaId != null) filtros.add('Zona ID: $zonaId');
    if (placa != null) filtros.add('Placa: $placa');
    if (estadoTicket != null) filtros.add('Estado: $estadoTicket');

    return filtros.isEmpty ? 'Sin filtros' : filtros.join(' | ');
  }

  @override
  String toString() {
    return 'FiltrosReporte('
        'tipo: $tipoReporte, '
        'formato: $formato, '
        'fechaInicio: $fechaInicio, '
        'fechaFin: $fechaFin, '
        'zonaId: $zonaId, '
        'placa: $placa'
        ')';
  }

  /// Convertir a JSON (para almacenamiento local si es necesario)
  Map<String, dynamic> toJson() {
    return {
      'tipoReporte': tipoReporte.value,
      'formato': formato.value,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaFin': fechaFin?.toIso8601String(),
      'zonaId': zonaId,
      'sedeId': sedeId,
      'grifoId': grifoId,
      'unidadId': unidadId,
      'placa': placa,
      'conductorId': conductorId,
      'rutaId': rutaId,
      'turnoId': turnoId,
      'estadoTicket': estadoTicket,
      'tipoCombustible': tipoCombustible,
      'soloCompletados': soloCompletados,
    };
  }

  /// Crear desde JSON
  factory FiltrosReporte.fromJson(Map<String, dynamic> json) {
    return FiltrosReporte(
      tipoReporte: TipoReporte.values.firstWhere(
        (e) => e.value == json['tipoReporte'],
        orElse: () => TipoReporte.abastecimientos,
      ),
      formato: FormatoExportacion.values.firstWhere(
        (e) => e.value == json['formato'],
        orElse: () => FormatoExportacion.excel,
      ),
      fechaInicio: json['fechaInicio'] != null
          ? DateTime.parse(json['fechaInicio'])
          : null,
      fechaFin:
          json['fechaFin'] != null ? DateTime.parse(json['fechaFin']) : null,
      zonaId: json['zonaId'],
      sedeId: json['sedeId'],
      grifoId: json['grifoId'],
      unidadId: json['unidadId'],
      placa: json['placa'],
      conductorId: json['conductorId'],
      rutaId: json['rutaId'],
      turnoId: json['turnoId'],
      estadoTicket: json['estadoTicket'],
      tipoCombustible: json['tipoCombustible'],
      soloCompletados: json['soloCompletados'],
    );
  }
}
class CreateTicketRequest {
  // Campos básicos obligatorios
  final int unidadId;
  final int conductorId;
  final int grifoId;
  final double kilometrajeActual;
  final String precintoNuevo;
  final double cantidad;
  final String tipoCombustible;

  // Campos opcionales básicos
  final double? kilometrajeAnterior;
  final String? fecha;
  final String? hora;
  final int? turnoId;
  final String? nivelCombustibleAntes;
  final String? observacionesSolicitud;

  // 🔥 NUEVOS CAMPOS PARA ITINERARIO/RUTA
  final int? rutaId;
  final int? itinerarioId;
  final int? ejecucionItinerarioId;
  final String? origenAsignacion; // AUTOMATICO, MANUAL, NINGUNO
  final String? motivoCambioItinerario;
  final int? itinerarioOriginalDetectadoId;

  CreateTicketRequest({
    required this.unidadId,
    required this.conductorId,
    required this.grifoId,
    required this.kilometrajeActual,
    required this.precintoNuevo,
    required this.cantidad,
    required this.tipoCombustible,
    this.kilometrajeAnterior,
    this.fecha,
    this.hora,
    this.turnoId,
    this.nivelCombustibleAntes,
    this.observacionesSolicitud,
    // 🔥 NUEVOS PARÁMETROS
    this.rutaId,
    this.itinerarioId,
    this.ejecucionItinerarioId,
    this.origenAsignacion,
    this.motivoCambioItinerario,
    this.itinerarioOriginalDetectadoId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'unidadId': unidadId,
      'conductorId': conductorId,
      'grifoId': grifoId,
      'kilometrajeActual': kilometrajeActual,
      'precintoNuevo': precintoNuevo,
      'cantidad': cantidad,
      'tipoCombustible': tipoCombustible,
    };

    // Agregar campos opcionales solo si tienen valor
    if (kilometrajeAnterior != null) {
      data['kilometrajeAnterior'] = kilometrajeAnterior;
    }
    if (fecha != null) data['fecha'] = fecha;
    if (hora != null) data['hora'] = hora;
    if (turnoId != null) data['turnoId'] = turnoId;
    if (nivelCombustibleAntes != null) {
      data['nivelCombustibleAntes'] = nivelCombustibleAntes;
    }
    if (observacionesSolicitud != null) {
      data['observacionesSolicitud'] = observacionesSolicitud;
    }

    // 🔥 NUEVOS CAMPOS DE ITINERARIO/RUTA
    if (rutaId != null) data['rutaId'] = rutaId;
    if (itinerarioId != null) data['itinerarioId'] = itinerarioId;
    if (ejecucionItinerarioId != null) {
      data['ejecucionItinerarioId'] = ejecucionItinerarioId;
    }
    if (origenAsignacion != null) {
      data['origenAsignacion'] = origenAsignacion;
    }
    if (motivoCambioItinerario != null) {
      data['motivoCambioItinerario'] = motivoCambioItinerario;
    }
    if (itinerarioOriginalDetectadoId != null) {
      data['itinerarioOriginalDetectadoId'] = itinerarioOriginalDetectadoId;
    }

    return data;
  }

  CreateTicketRequest copyWith({
    int? unidadId,
    int? conductorId,
    int? grifoId,
    double? kilometrajeActual,
    String? precintoNuevo,
    double? cantidad,
    String? tipoCombustible,
    double? kilometrajeAnterior,
    String? fecha,
    String? hora,
    int? turnoId,
    String? nivelCombustibleAntes,
    String? observacionesSolicitud,
    int? rutaId,
    int? itinerarioId,
    int? ejecucionItinerarioId,
    String? origenAsignacion,
    String? motivoCambioItinerario,
    int? itinerarioOriginalDetectadoId,
  }) {
    return CreateTicketRequest(
      unidadId: unidadId ?? this.unidadId,
      conductorId: conductorId ?? this.conductorId,
      grifoId: grifoId ?? this.grifoId,
      kilometrajeActual: kilometrajeActual ?? this.kilometrajeActual,
      precintoNuevo: precintoNuevo ?? this.precintoNuevo,
      cantidad: cantidad ?? this.cantidad,
      tipoCombustible: tipoCombustible ?? this.tipoCombustible,
      kilometrajeAnterior: kilometrajeAnterior ?? this.kilometrajeAnterior,
      fecha: fecha ?? this.fecha,
      hora: hora ?? this.hora,
      turnoId: turnoId ?? this.turnoId,
      nivelCombustibleAntes: nivelCombustibleAntes ?? this.nivelCombustibleAntes,
      observacionesSolicitud: observacionesSolicitud ?? this.observacionesSolicitud,
      rutaId: rutaId ?? this.rutaId,
      itinerarioId: itinerarioId ?? this.itinerarioId,
      ejecucionItinerarioId: ejecucionItinerarioId ?? this.ejecucionItinerarioId,
      origenAsignacion: origenAsignacion ?? this.origenAsignacion,
      motivoCambioItinerario: motivoCambioItinerario ?? this.motivoCambioItinerario,
      itinerarioOriginalDetectadoId: itinerarioOriginalDetectadoId ?? this.itinerarioOriginalDetectadoId,
    );
  }
}
// lib/domain/models/itinerario.dart

class Itinerario {
  final int id;
  final String nombre;
  final String codigo;
  final String? descripcion;
  final String tipoItinerario; // CIRCULAR, LINEAL, PUNTO_A_PUNTO
  final double distanciaTotal;
  final int tiempoEstimadoTotal;
  final List<String> diasOperacion;
  final String? horaInicioHabitual;
  final double? duracionEstimadaHoras;
  final String estado; // ACTIVO, INACTIVO, SUSPENDIDO
  final bool requiereSupervisor;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<TramoItinerario>? tramos;
  final int? unidadesAsignadas;
  final int? ejecucionesRealizadas;

  Itinerario({
    required this.id,
    required this.nombre,
    required this.codigo,
    this.descripcion,
    required this.tipoItinerario,
    required this.distanciaTotal,
    required this.tiempoEstimadoTotal,
    required this.diasOperacion,
    this.horaInicioHabitual,
    this.duracionEstimadaHoras,
    required this.estado,
    required this.requiereSupervisor,
    required this.createdAt,
    required this.updatedAt,
    this.tramos,
    this.unidadesAsignadas,
    this.ejecucionesRealizadas,
  });

  factory Itinerario.fromJson(Map<String, dynamic> json) {
    return Itinerario(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      descripcion: json['descripcion'],
      tipoItinerario: json['tipoItinerario'],
      distanciaTotal: double.parse(json['distanciaTotal'].toString()),
      tiempoEstimadoTotal: json['tiempoEstimadoTotal'],
      diasOperacion: List<String>.from(json['diasOperacion'] ?? []),
      horaInicioHabitual: json['horaInicioHabitual'],
      duracionEstimadaHoras: json['duracionEstimadaHoras'] != null
          ? double.parse(json['duracionEstimadaHoras'].toString())
          : null,
      estado: json['estado'],
      requiereSupervisor: json['requiereSupervisor'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      tramos: json['tramos'] != null
          ? (json['tramos'] as List)
              .map((t) => TramoItinerario.fromJson(t))
              .toList()
          : null,
      unidadesAsignadas: json['unidadesAsignadas'],
      ejecucionesRealizadas: json['ejecucionesRealizadas'],
    );
  }

  // Helpers útiles
  bool get esActivo => estado == 'ACTIVO';
  bool get esCircular => tipoItinerario == 'CIRCULAR';
  bool get operaHoy {
    final hoy = _getDiaSemana(DateTime.now().weekday);
    return diasOperacion.contains(hoy);
  }

  String _getDiaSemana(int weekday) {
    const dias = {
      1: 'LUNES',
      2: 'MARTES',
      3: 'MIERCOLES',
      4: 'JUEVES',
      5: 'VIERNES',
      6: 'SABADO',
      7: 'DOMINGO',
    };
    return dias[weekday] ?? '';
  }
}

class TramoItinerario {
  final int id;
  final int itinerarioId;
  final int rutaId;
  final RutaTramo ruta;
  final int orden;
  final String tipoTramo; // IDA, VUELTA, INTERMEDIO
  final String ciudadOrigen;
  final String ciudadDestino;
  final String? puntoParada;
  final String? direccionParada;
  final int? tiempoParadaMinutos;
  final bool esParadaObligatoria;
  final bool requiereInspeccion;
  final bool requiereAbastecimiento;
  final bool requiereDocumentacion;

  TramoItinerario({
    required this.id,
    required this.itinerarioId,
    required this.rutaId,
    required this.ruta,
    required this.orden,
    required this.tipoTramo,
    required this.ciudadOrigen,
    required this.ciudadDestino,
    this.puntoParada,
    this.direccionParada,
    this.tiempoParadaMinutos,
    required this.esParadaObligatoria,
    required this.requiereInspeccion,
    required this.requiereAbastecimiento,
    required this.requiereDocumentacion,
  });

  factory TramoItinerario.fromJson(Map<String, dynamic> json) {
    return TramoItinerario(
      id: json['id'],
      itinerarioId: json['itinerarioId'],
      rutaId: json['rutaId'],
      ruta: RutaTramo.fromJson(json['ruta']),
      orden: json['orden'],
      tipoTramo: json['tipoTramo'],
      ciudadOrigen: json['ciudadOrigen'],
      ciudadDestino: json['ciudadDestino'],
      puntoParada: json['puntoParada'],
      direccionParada: json['direccionParada'],
      tiempoParadaMinutos: json['tiempoParadaMinutos'],
      esParadaObligatoria: json['esParadaObligatoria'] ?? false,
      requiereInspeccion: json['requiereInspeccion'] ?? false,
      requiereAbastecimiento: json['requiereAbastecimiento'] ?? false,
      requiereDocumentacion: json['requiereDocumentacion'] ?? false,
    );
  }
}

class RutaTramo {
  final int id;
  final String nombre;
  final String codigo;
  final String origen;
  final String destino;
  final double distanciaKm;
  final int tiempoEstimadoMinutos;

  RutaTramo({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.tiempoEstimadoMinutos,
  });

  factory RutaTramo.fromJson(Map<String, dynamic> json) {
    return RutaTramo(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      origen: json['origen'],
      destino: json['destino'],
      distanciaKm: double.parse(json['distanciaKm'].toString()),
      tiempoEstimadoMinutos: json['tiempoEstimadoMinutos'],
    );
  }
}
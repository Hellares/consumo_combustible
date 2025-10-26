// lib/domain/models/itinerario_detectado_model.dart

/// Modelo que representa la respuesta de la detección automática de itinerario/ruta
class ItinerarioDetectado {
  /// Información del itinerario detectado (si existe)
  final ItinerarioInfo? itinerario;
  
  /// Información de la ruta detectada (si existe)
  final RutaInfo? ruta;
  
  /// ID de la ejecución de itinerario activa (si existe)
  final int? ejecucionItinerarioId;
  
  /// Origen de la detección: EJECUCION_ACTIVA, ITINERARIO_PERMANENTE, RUTA_EXCEPCIONAL, NINGUNO
  final String origen;
  
  /// Mensaje descriptivo de la detección
  final String mensaje;
  
  /// Indica si el controlador puede modificar la asignación
  final bool puedeModificar;
  
  /// Indica si se detectó alguna asignación
  final bool detectado;
  
  /// Día de la semana para la detección
  final String diaSemana;
  
  /// Fecha usada para la detección (YYYY-MM-DD)
  final String fecha;

  ItinerarioDetectado({
    this.itinerario,
    this.ruta,
    this.ejecucionItinerarioId,
    required this.origen,
    required this.mensaje,
    required this.puedeModificar,
    required this.detectado,
    required this.diaSemana,
    required this.fecha,
  });

  /// Crear desde JSON
  factory ItinerarioDetectado.fromJson(Map<String, dynamic> json) {
    return ItinerarioDetectado(
      itinerario: json['itinerario'] != null
          ? ItinerarioInfo.fromJson(json['itinerario'])
          : null,
      ruta: json['ruta'] != null
          ? RutaInfo.fromJson(json['ruta'])
          : null,
      ejecucionItinerarioId: json['ejecucionItinerarioId'],
      origen: json['origen'] ?? 'NINGUNO',
      mensaje: json['mensaje'] ?? '',
      puedeModificar: json['puedeModificar'] ?? true,
      detectado: json['detectado'] ?? false,
      diaSemana: json['diaSemana'] ?? '',
      fecha: json['fecha'] ?? '',
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'itinerario': itinerario?.toJson(),
      'ruta': ruta?.toJson(),
      'ejecucionItinerarioId': ejecucionItinerarioId,
      'origen': origen,
      'mensaje': mensaje,
      'puedeModificar': puedeModificar,
      'detectado': detectado,
      'diaSemana': diaSemana,
      'fecha': fecha,
    };
  }

  /// Helpers útiles
  bool get tieneItinerario => itinerario != null;
  bool get tieneRuta => ruta != null;
  bool get esAutomatico => origen != 'NINGUNO';
  bool get esEjecucionActiva => origen == 'EJECUCION_ACTIVA';
  bool get esItinerarioPermanente => origen == 'ITINERARIO_PERMANENTE';
  bool get esRutaExcepcional => origen == 'RUTA_EXCEPCIONAL';

  @override
  String toString() {
    return 'ItinerarioDetectado(origen: $origen, detectado: $detectado, mensaje: $mensaje)';
  }
}

/// Información básica de un itinerario
class ItinerarioInfo {
  final int id;
  final String nombre;
  final String codigo;
  final String tipoItinerario;
  final double? distanciaTotal;
  final List<String> diasOperacion;
  final String? horaInicioHabitual;

  ItinerarioInfo({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.tipoItinerario,
    this.distanciaTotal,
    required this.diasOperacion,
    this.horaInicioHabitual,
  });

  factory ItinerarioInfo.fromJson(Map<String, dynamic> json) {
    return ItinerarioInfo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'] ?? '',
      tipoItinerario: json['tipoItinerario'] ?? '',
      distanciaTotal: json['distanciaTotal'] != null
          ? (json['distanciaTotal'] as num).toDouble()
          : null,
      diasOperacion: json['diasOperacion'] != null
          ? List<String>.from(json['diasOperacion'])
          : [],
      horaInicioHabitual: json['horaInicioHabitual'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'tipoItinerario': tipoItinerario,
      'distanciaTotal': distanciaTotal,
      'diasOperacion': diasOperacion,
      'horaInicioHabitual': horaInicioHabitual,
    };
  }

  @override
  String toString() {
    return 'ItinerarioInfo(id: $id, nombre: $nombre, codigo: $codigo)';
  }
}

/// Información básica de una ruta
class RutaInfo {
  final int id;
  final String nombre;
  final String? codigo;
  final String? origen;
  final String? destino;
  final double? distanciaKm;

  RutaInfo({
    required this.id,
    required this.nombre,
    this.codigo,
    this.origen,
    this.destino,
    this.distanciaKm,
  });

  factory RutaInfo.fromJson(Map<String, dynamic> json) {
    return RutaInfo(
      id: json['id'],
      nombre: json['nombre'] ?? '',
      codigo: json['codigo'],
      origen: json['origen'],
      destino: json['destino'],
      distanciaKm: json['distanciaKm'] != null
          ? (json['distanciaKm'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'origen': origen,
      'destino': destino,
      'distanciaKm': distanciaKm,
    };
  }

  @override
  String toString() {
    return 'RutaInfo(id: $id, nombre: $nombre, origen: $origen, destino: $destino)';
  }
}
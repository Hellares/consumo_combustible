// lib/domain/models/mapa_ruta_data.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/models/tipo_visualizacion_ruta.dart';

/// Modelo que consolida toda la información necesaria para mostrar la ruta en el mapa
class MapaRutaData {
  /// Tipo de visualización (itinerario o ruta simple)
  final TipoVisualizacionRuta tipoVisualizacion;
  
  /// Información del itinerario completo (con tramos) - si aplica
  final Itinerario? itinerario;
  
  /// Información de la ruta simple - si aplica
  final Ruta? ruta;
  
  /// Metadata del ticket
  final int ticketId;
  final String placaUnidad;
  final DateTime? fecha;
  final String? conductorNombre;

  MapaRutaData({
    required this.tipoVisualizacion,
    this.itinerario,
    this.ruta,
    required this.ticketId,
    required this.placaUnidad,
    this.fecha,
    this.conductorNombre,
  });

  /// ¿Es visualización de itinerario?
  bool get esItinerario => tipoVisualizacion == TipoVisualizacionRuta.itinerario;

  /// ¿Es visualización de ruta simple?
  bool get esRutaSimple => tipoVisualizacion == TipoVisualizacionRuta.rutaSimple;

  /// ¿Tiene datos válidos para mostrar?
  Object? get tieneDatosValidos {
    if (esItinerario && itinerario != null) {
      return itinerario?.tramos?.isNotEmpty;
    }
    if (esRutaSimple && ruta != null) {
      return ruta!.destino ;
    }
    return false;
  }

  /// Obtener distancia total
  double? get distanciaTotal {
    if (esItinerario && itinerario != null) {
      return itinerario!.distanciaTotal;
    }
    if (esRutaSimple && ruta != null) {
      return ruta!.distanciaKm;
    }
    return null;
  }

  /// Obtener tiempo estimado total (en minutos)
  int? get tiempoEstimadoTotal {
    if (esItinerario && itinerario != null) {
      return itinerario!.tiempoEstimadoTotal;
    }
    if (esRutaSimple && ruta != null) {
      return ruta!.tiempoEstimadoMinutos;
    }
    return null;
  }

  /// Obtener cantidad de tramos
  int? get cantidadTramos {
    if (esItinerario && itinerario != null) {
      return itinerario!.tramos?.length;
    }
    return 1; // Ruta simple = 1 tramo
  }

  @override
  String toString() {
    return 'MapaRutaData(tipo: $tipoVisualizacion, ticketId: $ticketId, placa: $placaUnidad)';
  }
}
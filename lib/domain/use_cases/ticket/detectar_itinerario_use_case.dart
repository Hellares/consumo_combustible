// lib/domain/use_cases/ticket/detectar_itinerario_use_case.dart
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/domain/repository/ticket_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para detectar itinerario/ruta asignado a una unidad
class DetectarItinerarioUseCase {
  final TicketRepository repository;

  DetectarItinerarioUseCase(this.repository);

  /// Ejecuta la detección de itinerario/ruta
  /// 
  /// [unidadId] - ID de la unidad a consultar
  /// [fecha] - Fecha opcional en formato YYYY-MM-DD (si no se envía, usa la fecha actual)
  /// 
  /// Returns [Resource<ItinerarioDetectado>] con el resultado de la detección
  Future<Resource<ItinerarioDetectado>> run({
    required int unidadId,
    String? fecha,
  }) {
    return repository.detectarItinerario(
      unidadId: unidadId,
      fecha: fecha,
    );
  }
}
import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/models/ultimo_ticket_unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class TicketRepository {
  Future<Resource<TicketAbastecimiento>> createTicket(CreateTicketRequest request);

  Future<Resource<UltimoTicketUnidad>> getUltimoTicketByUnidad(int unidadId);

  Future<Resource<ItinerarioDetectado>> detectarItinerario({
    required int unidadId,
    String? fecha,
  });
}
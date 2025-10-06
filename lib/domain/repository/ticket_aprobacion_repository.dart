import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class TicketAprobacionRepository {
  Future<Resource<List<TicketAbastecimiento>>> getTicketsSolicitados();
  Future<Resource<TicketAbastecimiento>> aprobarTicket({
    required int ticketId,
    required int aprobadoPorId,
  });
  Future<Resource<TicketAbastecimiento>> rechazarTicket({
    required int ticketId,
    required int rechazadoPorId,
    required String motivo,
  });

  Future<Resource<Map<String, dynamic>>> aprobarTicketsLote({
    required List<int> ticketIds,
    required int aprobadoPorId,
  });
}
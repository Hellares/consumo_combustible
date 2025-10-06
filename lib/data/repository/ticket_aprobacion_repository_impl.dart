import 'package:consumo_combustible/data/datasource/remote/service/ticket_aprobacion_service.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class TicketAprobacionRepositoryImpl implements TicketAprobacionRepository {
  final TicketAprobacionService service;

  TicketAprobacionRepositoryImpl(this.service);

  @override
  Future<Resource<List<TicketAbastecimiento>>> getTicketsSolicitados() {
    return service.getTicketsSolicitados();
  }

  @override
  Future<Resource<TicketAbastecimiento>> aprobarTicket({
    required int ticketId,
    required int aprobadoPorId,
  }) {
    return service.aprobarTicket(
      ticketId: ticketId,
      aprobadoPorId: aprobadoPorId,
    );
  }

  @override
  Future<Resource<TicketAbastecimiento>> rechazarTicket({
    required int ticketId,
    required int rechazadoPorId,
    required String motivo,
  }) {
    return service.rechazarTicket(
      ticketId: ticketId,
      rechazadoPorId: rechazadoPorId,
      motivo: motivo,
    );
  }
  
  @override
  Future<Resource<Map<String, dynamic>>> aprobarTicketsLote(
    {required List<int> ticketIds, 
    required int aprobadoPorId
    }) {
    return service.aprobarTicketsLote(
      ticketIds: ticketIds,
      aprobadoPorId: aprobadoPorId,
    );
  }
}
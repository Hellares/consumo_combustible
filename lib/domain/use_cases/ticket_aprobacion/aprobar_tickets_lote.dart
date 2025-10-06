import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class AprobarTicketsLote {
  final TicketAprobacionRepository repository;

  AprobarTicketsLote(this.repository);

  Future<Resource<Map<String, dynamic>>> run({
    required List<int> ticketIds,
    required int aprobadoPorId,
  }) {
    return repository.aprobarTicketsLote(
      ticketIds: ticketIds,
      aprobadoPorId: aprobadoPorId,
    );
  }
}
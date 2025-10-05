import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class AprobarTicket {
  final TicketAprobacionRepository repository;

  AprobarTicket(this.repository);

  Future<Resource<TicketAbastecimiento>> run({
    required int ticketId,
    required int aprobadoPorId,
  }) {
    return repository.aprobarTicket(
      ticketId: ticketId,
      aprobadoPorId: aprobadoPorId,
    );
  }
}
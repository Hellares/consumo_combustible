import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class RechazarTicket {
  final TicketAprobacionRepository repository;

  RechazarTicket(this.repository);

  Future<Resource<TicketAbastecimiento>> run({
    required int ticketId,
    required int rechazadoPorId,
    required String motivo,
  }) {
    return repository.rechazarTicket(
      ticketId: ticketId,
      rechazadoPorId: rechazadoPorId,
      motivo: motivo,
    );
  }
}
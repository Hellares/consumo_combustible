import 'package:consumo_combustible/domain/use_cases/ticket/create_ticket_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/get_ultimo_ticket_by_unidad_use_case.dart';

class TicketUseCases {
  final CreateTicketUseCase createTicket;
  final GetUltimoTicketByUnidadUseCase getUltimoTicketByUnidad;
  TicketUseCases({
    required this.createTicket,
    required this.getUltimoTicketByUnidad,
  });
}
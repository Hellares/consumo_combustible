import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/aprobar_ticket.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/get_tickets_solicitados.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/rechazar_ticket.dart';

class TicketAprobacionUseCases {
  final GetTicketsSolicitados getTicketsSolicitados;
  final AprobarTicket aprobarTicket;
  final RechazarTicket rechazarTicket;

  TicketAprobacionUseCases({
    required this.getTicketsSolicitados,
    required this.aprobarTicket,
    required this.rechazarTicket,
  });
}
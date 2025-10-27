import 'package:consumo_combustible/domain/use_cases/ticket/create_ticket_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/detectar_itinerario_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/get_ultimo_ticket_by_unidad_use_case.dart';

class TicketUseCases {
  final CreateTicketUseCase createTicket;
  final GetUltimoTicketByUnidadUseCase getUltimoTicketByUnidad;
  final DetectarItinerarioUseCase detectarItinerario;
  TicketUseCases({
    required this.createTicket,
    required this.getUltimoTicketByUnidad,
    required this.detectarItinerario,
  });
}
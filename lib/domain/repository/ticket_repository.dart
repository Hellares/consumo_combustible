import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class TicketRepository {
  Future<Resource<TicketAbastecimiento>> createTicket(CreateTicketRequest request);
}
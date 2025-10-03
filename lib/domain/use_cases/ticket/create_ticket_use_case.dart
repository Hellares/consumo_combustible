import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateTicketUseCase {
  final TicketRepository repository;
  CreateTicketUseCase(this.repository);

  Future<Resource<TicketAbastecimiento>> run(CreateTicketRequest request) =>
      repository.createTicket(request);
}
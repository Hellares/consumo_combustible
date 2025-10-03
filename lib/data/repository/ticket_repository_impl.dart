import 'package:consumo_combustible/data/datasource/remote/service/ticket_service.dart';
import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class TicketRepositoryImpl implements TicketRepository {
  final TicketService service;
  TicketRepositoryImpl(this.service);

  @override
  Future<Resource<TicketAbastecimiento>> createTicket(
    CreateTicketRequest request,
  ) => service.createTicket(request);
}
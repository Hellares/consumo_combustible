import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetTicketsSolicitados {
  final TicketAprobacionRepository repository;

  GetTicketsSolicitados(this.repository);

  Future<Resource<List<TicketAbastecimiento>>> run() {
    return repository.getTicketsSolicitados();
  }
}
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetArchivosByTicketUseCase {
  final ArchivoRepository _repository;

  GetArchivosByTicketUseCase(this._repository);

  Future<Resource<List<ArchivoTicket>>> run(int ticketId) {
    if (ticketId <= 0) {
      return Future.value(Error('ID de ticket inválido'));
    }
    return _repository.getArchivosByTicket(ticketId);
  }
}

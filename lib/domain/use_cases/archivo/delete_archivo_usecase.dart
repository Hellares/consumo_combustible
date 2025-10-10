import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class DeleteArchivoUseCase {
  final ArchivoRepository _repository;

  DeleteArchivoUseCase(this._repository);

  Future<Resource<void>> run(int archivoId, int ticketId) {
    if (archivoId <= 0) {
      return Future.value(Error('ID de archivo inválido'));
    }
    if (ticketId <= 0) {
      return Future.value(Error('ID de ticket inválido'));
    }
    return _repository.deleteArchivo(archivoId, ticketId);
  }
}
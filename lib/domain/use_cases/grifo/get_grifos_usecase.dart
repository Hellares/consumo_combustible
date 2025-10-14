import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetGrifosUseCase {
  final GrifoRepository repository;

  GetGrifosUseCase(this.repository);

  Future<Resource<List<Grifo>>> run() {
    return repository.getGrifos();
  }
}
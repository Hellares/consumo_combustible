import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetGrifosGrifosBySedeUseCase {
  final GrifoRepository repository;

  GetGrifosGrifosBySedeUseCase(this.repository);

  Future<Resource<List<Grifo>>> run(int sedeId) {
    return repository.getGrifosBySede(sedeId);
  }
}
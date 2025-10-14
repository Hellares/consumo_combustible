import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetGrifoByIdUseCase {
  final GrifoRepository repository;

  GetGrifoByIdUseCase(this.repository);

  Future<Resource<Grifo>> run(int id) {
    return repository.getGrifoById(id);
  }
}
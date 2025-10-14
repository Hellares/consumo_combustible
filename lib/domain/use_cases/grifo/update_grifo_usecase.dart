
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class UpdateGrifoUseCase {
  final GrifoRepository repository;

  UpdateGrifoUseCase(this.repository);

  Future<Resource<Grifo>> run(int id, CreateGrifoRequest request) {
    return repository.updateGrifo(id, request);
  }
}
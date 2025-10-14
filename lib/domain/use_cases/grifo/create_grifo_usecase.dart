
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateGrifoUseCase {
  final GrifoRepository repository;

  CreateGrifoUseCase(this.repository);

  Future<Resource<Grifo>> run(CreateGrifoRequest request) {
    return repository.createGrifo(request);
  }
}
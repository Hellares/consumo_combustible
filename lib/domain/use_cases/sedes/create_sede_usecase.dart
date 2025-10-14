
import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/repository/sede_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateSedeUseCase {
  final SedeRepository repository;

  CreateSedeUseCase(this.repository);

  Future<Resource<Sede>> run(CreateSedeRequest request) {
    return repository.createSede(request);
  }
}
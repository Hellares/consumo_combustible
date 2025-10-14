import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/repository/sede_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetSedesUseCase {
  final SedeRepository repository;

  GetSedesUseCase(this.repository);

  Future<Resource<List<Sede>>> run() {
    return repository.getSedes();
  }
}
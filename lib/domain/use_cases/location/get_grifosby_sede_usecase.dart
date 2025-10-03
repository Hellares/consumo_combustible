import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetGrifosBySedeUseCase {
  final LocationRepository repository;
  GetGrifosBySedeUseCase(this.repository);
  Future<Resource<List<Grifo>>> run(int sedeId) => 
      repository.getGrifosBySede(sedeId);
}
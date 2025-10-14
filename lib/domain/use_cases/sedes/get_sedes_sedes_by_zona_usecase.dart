import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/repository/sede_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetSedesSedesByZonaUseCase {
  final SedeRepository repository;

  GetSedesSedesByZonaUseCase(this.repository);

  Future<Resource<List<Sede>>> run(int zonaId) {
    return repository.getSedesByZona(zonaId);
  }
}
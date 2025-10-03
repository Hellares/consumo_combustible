import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetSedesByZonaUseCase {
  final LocationRepository repository;
  GetSedesByZonaUseCase(this.repository);
  Future<Resource<List<Sede>>> run(int zonaId) => 
      repository.getSedesByZona(zonaId);
}
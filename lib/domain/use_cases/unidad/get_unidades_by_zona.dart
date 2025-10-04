import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetUnidadesByZona {
  final UnidadRepository unidadRepository;

  GetUnidadesByZona(this.unidadRepository);

  Future<Resource<List<Unidad>>> run(int zonaId) {
    return unidadRepository.getUnidadesByZona(zonaId);
  }
}
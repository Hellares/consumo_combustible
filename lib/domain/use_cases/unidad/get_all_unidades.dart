import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetAllUnidades {
  final UnidadRepository unidadRepository;

  GetAllUnidades(this.unidadRepository);

  Future<Resource<List<Unidad>>> run({int page = 1, int pageSize = 100}) {
    return unidadRepository.getAllUnidades(page: page, pageSize: pageSize);
  }
}
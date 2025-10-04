import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetUnidadById {
  final UnidadRepository unidadRepository;

  GetUnidadById(this.unidadRepository);

  Future<Resource<Unidad>> run(int unidadId) {
    return unidadRepository.getUnidadById(unidadId);
  }
}
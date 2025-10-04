import 'package:consumo_combustible/domain/repository/unidad_repository.dart';

class ClearUnidadesCache {
  final UnidadRepository unidadRepository;

  ClearUnidadesCache(this.unidadRepository);

  Future<void> run({int? zonaId}) {
    return unidadRepository.clearUnidadesCache(zonaId: zonaId);
  }
}
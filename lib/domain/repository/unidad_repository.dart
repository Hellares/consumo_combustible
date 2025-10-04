import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class UnidadRepository {
  Future<Resource<List<Unidad>>> getUnidadesByZona(int zonaId);
  Future<Resource<List<Unidad>>> getAllUnidades({int page, int pageSize});
  Future<Resource<Unidad>> getUnidadById(int unidadId);

  Future<List<Unidad>?> getCachedUnidades(int zonaId);
  Future<void> cacheUnidades(int zonaId, List<Unidad> unidades);
  Future<void> clearUnidadesCache({int? zonaId});
}
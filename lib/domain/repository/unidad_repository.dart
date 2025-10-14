import 'package:consumo_combustible/domain/models/create_unidad_request.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class UnidadRepository {
  Future<Resource<List<Unidad>>> getUnidadesByZona(int zonaId);
  // Future<Resource<List<Unidad>>> getAllUnidades({int page, int pageSize});
  Future<Resource<UnidadesResponse>> getAllUnidades({
    int page = 1,
    int pageSize = 10,
  });

  Future<Resource<Unidad>> createUnidad(CreateUnidadRequest request);
  
  Future<Resource<Unidad>> getUnidadById(int unidadId);

  Future<List<Unidad>?> getCachedUnidades(int zonaId);
  Future<void> cacheUnidades(int zonaId, List<Unidad> unidades);
  Future<void> clearUnidadesCache({int? zonaId});
}
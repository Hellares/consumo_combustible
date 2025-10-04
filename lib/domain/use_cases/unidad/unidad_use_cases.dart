import 'package:consumo_combustible/domain/use_cases/unidad/clear_unidades_cache.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_all_unidades.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_unidad_by_id.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_unidades_by_zona.dart';

class UnidadUseCases {
  final GetUnidadesByZona getUnidadesByZona;
  final GetAllUnidades getAllUnidades;
  final GetUnidadById getUnidadById;
  final ClearUnidadesCache clearUnidadesCache;

  UnidadUseCases({
    required this.getUnidadesByZona,
    required this.getAllUnidades,
    required this.getUnidadById,
    required this.clearUnidadesCache,
  });
}
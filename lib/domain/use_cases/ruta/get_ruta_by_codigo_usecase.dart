// lib/domain/use_cases/ruta/get_ruta_by_codigo_usecase.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/repository/ruta_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetRutaByCodigoUseCase {
  final RutaRepository _repository;

  GetRutaByCodigoUseCase(this._repository);

  Future<Resource<Ruta>> run(String codigo) async {
    return await _repository.getRutaByCodigo(codigo);
  }
}
// lib/domain/use_cases/ruta/get_ruta_by_id_usecase.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/repository/ruta_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetRutaByIdUseCase {
  final RutaRepository _repository;

  GetRutaByIdUseCase(this._repository);

  Future<Resource<Ruta>> run(int id) async {
    return await _repository.getRutaById(id);
  }
}
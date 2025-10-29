// lib/domain/use_cases/itinerario/get_itinerario_by_codigo_usecase.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/repository/itinerario_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetItinerarioByCodigoUseCase {
  final ItinerarioRepository _repository;

  GetItinerarioByCodigoUseCase(this._repository);

  Future<Resource<Itinerario>> run(String codigo) async {
    return await _repository.getItinerarioByCodigo(codigo);
  }
}
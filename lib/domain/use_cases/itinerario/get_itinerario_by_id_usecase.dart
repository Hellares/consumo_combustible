// lib/domain/use_cases/itinerario/get_itinerario_by_id_usecase.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/repository/itinerario_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetItinerarioByIdUseCase {
  final ItinerarioRepository _repository;

  GetItinerarioByIdUseCase(this._repository);

  Future<Resource<Itinerario>> run(int id) async {
    return await _repository.getItinerarioById(id);
  }
}
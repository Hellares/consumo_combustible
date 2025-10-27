// lib/domain/use_cases/itinerario/get_itinerarios_activos_use_case.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/repository/itinerario_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetItinerariosActivosUseCase {
  final ItinerarioRepository repository;

  GetItinerariosActivosUseCase(this.repository);

  Future<Resource<List<Itinerario>>> run() {
    return repository.getItinerariosActivos();
  }
}
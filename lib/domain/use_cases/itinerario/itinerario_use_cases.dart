// lib/domain/use_cases/itinerario/itinerario_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/itinerario/get_itinerarios_activos_use_case.dart';

class ItinerarioUseCases {
  final GetItinerariosActivosUseCase getItinerariosActivos;

  ItinerarioUseCases({
    required this.getItinerariosActivos,
  });
}
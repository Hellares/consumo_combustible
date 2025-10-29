// lib/domain/use_cases/itinerario/itinerario_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/itinerario/get_itinerario_by_codigo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/itinerario/get_itinerario_by_id_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/itinerario/get_itinerarios_activos_use_case.dart';

class ItinerarioUseCases {
  final GetItinerariosActivosUseCase getItinerariosActivos;
  final GetItinerarioByIdUseCase getItinerarioById;
  final GetItinerarioByCodigoUseCase getItinerarioByCodigo; 

  ItinerarioUseCases({
    required this.getItinerariosActivos,
    required this.getItinerarioById,
    required this.getItinerarioByCodigo,
  });
}
import 'package:consumo_combustible/domain/use_cases/location/clear_selected_location_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_grifosby_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_sedesby_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_selected_location_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_zonas_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/save_selected_location_usecase.dart';

class LocationUseCases {
  final GetZonasUseCase getZonas;
  final GetSedesByZonaUseCase getSedesByZona;
  final GetGrifosBySedeUseCase getGrifosBySede;
  final SaveSelectedLocationUseCase saveSelectedLocation;
  final GetSelectedLocationUseCase getSelectedLocation;
  final ClearSelectedLocationUseCase clearSelectedLocation;

  LocationUseCases({
    required this.getZonas,
    required this.getSedesByZona,
    required this.getGrifosBySede,
    required this.saveSelectedLocation,
    required this.getSelectedLocation,
    required this.clearSelectedLocation,
  });
}
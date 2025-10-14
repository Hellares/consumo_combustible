import 'package:consumo_combustible/domain/use_cases/zona/create_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/zona/get_zonas_zonas_usecase.dart';

class ZonaUseCases {
  final CreateZonaUseCase createZona;
  final GetZonasZonasUseCase getZonas;

  ZonaUseCases({
    required this.createZona,
    required this.getZonas,
  });
}
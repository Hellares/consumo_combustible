import 'package:consumo_combustible/domain/use_cases/sedes/create_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/get_sedes_sedes_by_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/get_sedes_usecase.dart';

class SedeUseCases {
  final CreateSedeUseCase createSede;
  final GetSedesUseCase getSedes;
  final GetSedesSedesByZonaUseCase getSedesSedesByZona;

  SedeUseCases({
    required this.createSede,
    required this.getSedes,
    required this.getSedesSedesByZona,
  });
}
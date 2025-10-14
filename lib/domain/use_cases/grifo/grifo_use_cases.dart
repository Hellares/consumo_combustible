import 'package:consumo_combustible/domain/use_cases/grifo/create_grifo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifo_by_id_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifosgrifos_by_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifos_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/update_grifo_usecase.dart';

class GrifoUseCases {
  final CreateGrifoUseCase createGrifo;
  final GetGrifosUseCase getGrifos;
  final GetGrifosGrifosBySedeUseCase getGrifosBySede;
  final GetGrifoByIdUseCase getGrifoById;
  final UpdateGrifoUseCase updateGrifo;

  GrifoUseCases({
    required this.createGrifo,
    required this.getGrifos,
    required this.getGrifosBySede,
    required this.getGrifoById,
    required this.updateGrifo,
  });
}
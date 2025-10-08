
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencia_by_id_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_by_usuario_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_vencidas_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_proximas_vencer_use_case.dart';

class LicenciaUseCases {
  final GetLicenciasUseCase getLicencias;
  final GetLicenciaByIdUseCase getLicenciaById;
  final GetLicenciasByUsuarioUseCase getLicenciasByUsuario;
  final GetLicenciasVencidasUseCase getLicenciasVencidas;
  final GetLicenciasProximasVencerUseCase getLicenciasProximasVencer;

  LicenciaUseCases({
    required this.getLicencias,
    required this.getLicenciaById,
    required this.getLicenciasByUsuario,
    required this.getLicenciasVencidas,
    required this.getLicenciasProximasVencer,
  });
}
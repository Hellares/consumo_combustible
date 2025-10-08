
// lib/domain/use_cases/licencia/licencia_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/licencia/create_licencia_use_case.dart';
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
  final CreateLicenciaUseCase createLicencia;

  LicenciaUseCases({
    required this.getLicencias,
    required this.getLicenciaById,
    required this.getLicenciasByUsuario,
    required this.getLicenciasVencidas,
    required this.getLicenciasProximasVencer,
    required this.createLicencia,
  });
}
// lib/domain/use_cases/ruta/ruta_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/ruta/get_ruta_by_codigo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/ruta/get_ruta_by_id_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/ruta/get_rutas_activas_use_case.dart';

class RutaUseCases {
  final GetRutasActivasUseCase getRutasActivas;
  final GetRutaByIdUseCase getRutaById; 
  final GetRutaByCodigoUseCase getRutaByCodigo; 


  RutaUseCases({
    required this.getRutasActivas,
    required this.getRutaById,
    required this.getRutaByCodigo,
  });
}
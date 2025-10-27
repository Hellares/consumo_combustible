// lib/domain/use_cases/ruta/ruta_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/ruta/get_rutas_activas_use_case.dart';

class RutaUseCases {
  final GetRutasActivasUseCase getRutasActivas;

  RutaUseCases({
    required this.getRutasActivas,
  });
}
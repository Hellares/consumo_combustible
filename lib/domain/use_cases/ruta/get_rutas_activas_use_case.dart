// lib/domain/use_cases/ruta/get_rutas_activas_use_case.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/repository/ruta_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetRutasActivasUseCase {
  final RutaRepository repository;

  GetRutasActivasUseCase(this.repository);

  Future<Resource<List<Ruta>>> run() {
    return repository.getRutasActivas();
  }
}
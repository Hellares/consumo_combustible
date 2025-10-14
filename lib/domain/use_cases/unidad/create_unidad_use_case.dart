// lib/domain/use_cases/unidad/create_unidad_use_case.dart

import 'package:consumo_combustible/domain/models/create_unidad_request.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateUnidadUseCase {
  final UnidadRepository repository;

  CreateUnidadUseCase(this.repository);

  Future<Resource<Unidad>> run(CreateUnidadRequest request) {
    return repository.createUnidad(request);
  }
}
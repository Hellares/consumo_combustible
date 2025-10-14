// lib/domain/use_cases/rol/activar_rol_use_case.dart

import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class ActivarRolUseCase {
  final RolRepository repository;

  ActivarRolUseCase(this.repository);

  Future<Resource<Rol>> run(int rolId) {
    return repository.activarRol(rolId);
  }
}
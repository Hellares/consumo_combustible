// lib/domain/use_cases/rol/delete_rol_use_case.dart

import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class DeleteRolUseCase {
  final RolRepository repository;

  DeleteRolUseCase(this.repository);

  Future<Resource<void>> run(int rolId) {
    return repository.deleteRol(rolId);
  }
}
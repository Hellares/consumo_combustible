// lib/domain/use_cases/rol/get_roles_use_case.dart

import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetRolesUseCase {
  final RolRepository repository;

  GetRolesUseCase(this.repository);

  Future<Resource<RolesResponse>> run({
    int page = 1,
    int limit = 10,
  }) {
    return repository.getRoles(page: page, limit: limit);
  }
}
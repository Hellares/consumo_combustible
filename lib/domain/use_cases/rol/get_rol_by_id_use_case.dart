// lib/domain/use_cases/rol/get_rol_by_id_use_case.dart

import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetRolByIdUseCase {
  final RolRepository repository;

  GetRolByIdUseCase(this.repository);

  Future<Resource<Rol>> run(int rolId) {
    return repository.getRolById(rolId);
  }
}
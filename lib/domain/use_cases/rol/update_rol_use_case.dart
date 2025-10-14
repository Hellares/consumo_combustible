// lib/domain/use_cases/rol/update_rol_use_case.dart

import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class UpdateRolUseCase {
  final RolRepository repository;

  UpdateRolUseCase(this.repository);

  Future<Resource<Rol>> run(int rolId, CreateRolRequest request) {
    return repository.updateRol(rolId, request);
  }
}
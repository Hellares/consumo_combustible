// lib/domain/use_cases/rol/create_rol_use_case.dart

import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateRolUseCase {
  final RolRepository repository;

  CreateRolUseCase(this.repository);

  Future<Resource<Rol>> run(CreateRolRequest request) {
    return repository.createRol(request);
  }
}
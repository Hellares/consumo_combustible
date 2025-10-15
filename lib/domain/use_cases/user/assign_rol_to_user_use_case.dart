// lib/domain/use_cases/user/assign_rol_to_user_use_case.dart

import 'package:consumo_combustible/domain/models/rol_asignado.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class AssignRolToUserUseCase {
  final UserRepository repository;

  AssignRolToUserUseCase(this.repository);

  Future<Resource<RolAsignado>> run({
    required int userId,
    required int rolId,
    required int asignadoPorId,
  }) {
    return repository.assignRolToUser(
      userId: userId,
      rolId: rolId,
      asignadoPorId: asignadoPorId,
    );
  }
}
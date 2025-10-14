// lib/domain/use_cases/rol/rol_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/rol/activar_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/create_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/delete_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/get_rol_by_id_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/get_roles_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/update_rol_use_case.dart';

class RolUseCases {
  final GetRolesUseCase getRoles;
  final GetRolByIdUseCase getRolById;
  final CreateRolUseCase createRol;
  final UpdateRolUseCase updateRol;
  final DeleteRolUseCase deleteRol;
  final ActivarRolUseCase activarRol;

  RolUseCases({
    required this.getRoles,
    required this.getRolById,
    required this.createRol,
    required this.updateRol,
    required this.deleteRol,
    required this.activarRol,
  });
}
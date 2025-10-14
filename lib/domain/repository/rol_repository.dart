// lib/domain/repository/rol_repository.dart

import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class RolRepository {
  /// Obtiene todos los roles
  Future<Resource<RolesResponse>> getRoles({
    int page = 1,
    int limit = 10,
  });

  /// Obtiene un rol por su ID
  Future<Resource<Rol>> getRolById(int rolId);

  /// Crea un nuevo rol
  Future<Resource<Rol>> createRol(CreateRolRequest request);

  /// Actualiza un rol existente
  Future<Resource<Rol>> updateRol(int rolId, CreateRolRequest request);

  /// Elimina (desactiva) un rol
  Future<Resource<void>> deleteRol(int rolId);

  /// Activa un rol previamente desactivado
  Future<Resource<Rol>> activarRol(int rolId);
}
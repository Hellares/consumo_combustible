// lib/data/repository/rol_repository_impl.dart

import 'package:consumo_combustible/data/datasource/remote/service/rol_service.dart';
import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class RolRepositoryImpl implements RolRepository {
  final RolService service;

  RolRepositoryImpl(this.service);

  @override
  Future<Resource<RolesResponse>> getRoles({
    int page = 1,
    int limit = 10,
  }) {
    return service.getRoles(page: page, limit: limit);
  }

  @override
  Future<Resource<Rol>> getRolById(int rolId) {
    return service.getRolById(rolId);
  }

  @override
  Future<Resource<Rol>> createRol(CreateRolRequest request) {
    return service.createRol(request);
  }

  @override
  Future<Resource<Rol>> updateRol(int rolId, CreateRolRequest request) {
    return service.updateRol(rolId, request);
  }

  @override
  Future<Resource<void>> deleteRol(int rolId) {
    return service.deleteRol(rolId);
  }

  @override
  Future<Resource<Rol>> activarRol(int rolId) {
    return service.activarRol(rolId);
  }
}
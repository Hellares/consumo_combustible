// lib/data/repository/ruta_repository_impl.dart

import 'package:consumo_combustible/data/datasource/remote/service/ruta_service.dart';
import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/repository/ruta_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class RutaRepositoryImpl implements RutaRepository {
  final RutaService service;

  RutaRepositoryImpl(this.service);

  @override
  Future<Resource<List<Ruta>>> getRutasActivas() {
    return service.getRutasActivas();
  }

  @override
  Future<Resource<Ruta>> getRutaById(int id) {
    return service.getRutaById(id);
  }

  @override
  Future<Resource<Ruta>> getRutaByCodigo(String codigo) {
    return service.getRutaByCodigo(codigo);
  }
}
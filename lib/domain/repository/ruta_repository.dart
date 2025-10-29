// lib/domain/repository/ruta_repository.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class RutaRepository {
  Future<Resource<List<Ruta>>> getRutasActivas();

  Future<Resource<Ruta>> getRutaById(int id);

  Future<Resource<Ruta>> getRutaByCodigo(String codigo);
}
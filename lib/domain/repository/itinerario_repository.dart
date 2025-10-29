// lib/domain/repository/itinerario_repository.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class ItinerarioRepository {
  Future<Resource<List<Itinerario>>> getItinerariosActivos();

  Future<Resource<Itinerario>> getItinerarioById(int id);

  Future<Resource<Itinerario>> getItinerarioByCodigo(String codigo);
}
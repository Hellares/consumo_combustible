// lib/data/repository/itinerario_repository_impl.dart

import 'package:consumo_combustible/data/datasource/remote/service/itinerario_service.dart';
import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/repository/itinerario_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class ItinerarioRepositoryImpl implements ItinerarioRepository {
  final ItinerarioService service;

  ItinerarioRepositoryImpl(this.service);

  @override
  Future<Resource<List<Itinerario>>> getItinerariosActivos() {
    return service.getItinerariosActivos();
  }
  
  @override
  Future<Resource<Itinerario>> getItinerarioByCodigo(String codigo) {
    return service.getItinerarioByCodigo(codigo);
  }
  
  @override
  Future<Resource<Itinerario>> getItinerarioById(int id) {
    return service.getItinerarioById(id);
  }
}
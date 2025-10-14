import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class SedeRepository {
  /// Crear nueva sede
  Future<Resource<Sede>> createSede(CreateSedeRequest request);
  
  /// Obtener todas las sedes
  Future<Resource<List<Sede>>> getSedes();
  
  /// Obtener sedes por zona
  Future<Resource<List<Sede>>> getSedesByZona(int zonaId);
  
  /// Obtener sede por ID
  Future<Resource<Sede>> getSedeById(int id);
  
  /// Actualizar sede
  Future<Resource<Sede>> updateSede(int id, CreateSedeRequest request);
  
  /// Eliminar sede
  Future<Resource<void>> deleteSede(int id);
}
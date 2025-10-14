
import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class ZonaRepository {
  /// Crear nueva zona
  Future<Resource<Zona>> createZona(CreateZonaRequest request);
  
  /// Obtener todas las zonas
  Future<Resource<List<Zona>>> getZonas();
  
  /// Obtener zona por ID
  Future<Resource<Zona>> getZonaById(int id);
  
  /// Actualizar zona
  Future<Resource<Zona>> updateZona(int id, CreateZonaRequest request);
  
  /// Eliminar zona
  Future<Resource<void>> deleteZona(int id);
}
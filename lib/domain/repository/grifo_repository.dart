
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class GrifoRepository {
  /// Crear nuevo grifo
  Future<Resource<Grifo>> createGrifo(CreateGrifoRequest request);
  
  /// Obtener todos los grifos
  Future<Resource<List<Grifo>>> getGrifos();
  
  /// Obtener grifos por sede
  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId);
  
  /// Obtener grifo por ID
  Future<Resource<Grifo>> getGrifoById(int id);
  
  /// Actualizar grifo
  Future<Resource<Grifo>> updateGrifo(int id, CreateGrifoRequest request);
  
  /// Eliminar grifo
  Future<Resource<void>> deleteGrifo(int id);
}
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class LocationRepository {
  Future<Resource<List<Zona>>> getZonas();
  Future<Resource<List<Sede>>> getSedesByZona(int zonaId);
  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId);
  
  // Guardar selección
  Future<void> saveSelectedLocation(SelectedLocation location);
  Future<SelectedLocation?> getSelectedLocation();
  Future<void> clearSelectedLocation();
}

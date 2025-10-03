import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/location_service.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
// import 'package:flutter/foundation.dart';


class LocationRepositoryImpl implements LocationRepository {
  final LocationService service;
  final FastStorageService storage;

  LocationRepositoryImpl(this.service, this.storage);

  @override
  Future<Resource<List<Zona>>> getZonas() => service.getZonas();
  // @override
  // Future<Resource<List<Zona>>> getZonas() async {
  //   if (kDebugMode) print('📍 [Repository] Obteniendo zonas...');
  //   final result = await service.getZonas();
    
  //   if (kDebugMode) {
  //     if (result is Success) {
  //       print('✅ [Repository] Zonas obtenidas: ${(result.data as List).length}');
  //     } else if (result is Error) {
  //       print('❌ [Repository] Error: ${result.message}');
  //     }
  //   }
    
  //   return result;
  // }

  @override
  Future<Resource<List<Sede>>> getSedesByZona(int zonaId) => 
      service.getSedesByZona(zonaId);

  @override
  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId) => 
      service.getGrifosBySede(sedeId);

  @override
  Future<void> saveSelectedLocation(SelectedLocation location) async {
    await storage.write('selected_location', location.toJson());
  }

  @override
  Future<SelectedLocation?> getSelectedLocation() async {
    final data = await storage.read('selected_location');
    if (data != null) {
      return SelectedLocation.fromJson(data);
    }
    return null;
  }

  @override
  Future<void> clearSelectedLocation() async {
    await storage.delete('selected_location');
  }
}


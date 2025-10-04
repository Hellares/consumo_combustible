// import 'package:consumo_combustible/data/datasource/remote/service/unidad_service.dart';
// import 'package:consumo_combustible/domain/models/unidad.dart';
// import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
// import 'package:consumo_combustible/domain/utils/resource.dart';

// class UnidadRepositoryImpl implements UnidadRepository {
//   final UnidadService unidadService;

//   UnidadRepositoryImpl(this.unidadService);

//   @override
//   Future<Resource<List<Unidad>>> getUnidadesByZona(int zonaId) {
//     return unidadService.getUnidadesByZona(zonaId);
//   }

//   @override
//   Future<Resource<List<Unidad>>> getAllUnidades({
//     int page = 1,
//     int pageSize = 100,
//   }) {
//     return unidadService.getAllUnidades(page: page, pageSize: pageSize);
//   }

//   @override
//   Future<Resource<Unidad>> getUnidadById(int unidadId) {
//     return unidadService.getUnidadById(unidadId);
//   }
// }

// lib/data/repository/unidad_repository_impl.dart

import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/unidad_service.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

class UnidadRepositoryImpl implements UnidadRepository {
  final UnidadService unidadService;
  final FastStorageService storage;

  UnidadRepositoryImpl(this.unidadService, this.storage);

  static const String _cachePrefix = 'unidades_zona_';

  @override
  Future<Resource<List<Unidad>>> getUnidadesByZona(int zonaId) async {
    try {
      // 1️⃣ Intentar obtener del caché
      final cachedUnidades = await getCachedUnidades(zonaId);
      
      if (cachedUnidades != null && cachedUnidades.isNotEmpty) {
        if (kDebugMode) {
          print('✅ [Cache] ${cachedUnidades.length} unidades del caché (zona: $zonaId)');
        }
        return Success(cachedUnidades);
      }

      // 2️⃣ Si no hay caché, obtener del servidor
      if (kDebugMode) {
        print('📡 [Cache] Obteniendo del servidor (zona: $zonaId)...');
      }

      final response = await unidadService.getUnidadesByZona(zonaId);

      // 3️⃣ Guardar en caché si fue exitoso
      if (response is Success<List<Unidad>>) {
        await cacheUnidades(zonaId, response.data);
      }

      return response;

    } catch (e) {
      if (kDebugMode) {
        print('❌ [Cache] Error: $e');
      }
      return Error('Error al obtener unidades: $e');
    }
  }

  @override
  Future<List<Unidad>?> getCachedUnidades(int zonaId) async {
    try {
      final cacheKey = '$_cachePrefix$zonaId';
      final cachedData = await storage.read(cacheKey);
      
      if (cachedData != null && cachedData is List) {
        final unidades = cachedData
            .map((json) => Unidad.fromJson(json as Map<String, dynamic>))
            .toList();
        return unidades;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Cache] Error al leer: $e');
      }
      return null;
    }
  }

  @override
  Future<void> cacheUnidades(int zonaId, List<Unidad> unidades) async {
    try {
      final cacheKey = '$_cachePrefix$zonaId';
      final dataToCache = unidades.map((u) => u.toJson()).toList();
      await storage.write(cacheKey, dataToCache);

      if (kDebugMode) {
        print('💾 [Cache] ${unidades.length} unidades guardadas (zona: $zonaId)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Cache] Error al guardar: $e');
      }
    }
  }

  @override
  Future<void> clearUnidadesCache({int? zonaId}) async {
    try {
      if (zonaId != null) {
        await storage.delete('$_cachePrefix$zonaId');
        if (kDebugMode) {
          print('🗑️ [Cache] Limpiado (zona: $zonaId)');
        }
      } else {
        // Limpiar todas las zonas conocidas (ajustar según necesidad)
        for (int i = 1; i <= 20; i++) {
          await storage.delete('$_cachePrefix$i');
        }
        if (kDebugMode) {
          print('🗑️ [Cache] Todo el caché limpiado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Cache] Error al limpiar: $e');
      }
    }
  }

  @override
  Future<Resource<List<Unidad>>> getAllUnidades({
    int page = 1,
    int pageSize = 100,
  }) {
    return unidadService.getAllUnidades(page: page, pageSize: pageSize);
  }

  @override
  Future<Resource<Unidad>> getUnidadById(int unidadId) {
    return unidadService.getUnidadById(unidadId);
  }
}
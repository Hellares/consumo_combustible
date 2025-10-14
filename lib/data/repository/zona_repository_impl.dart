import 'package:consumo_combustible/data/datasource/remote/service/zona_service.dart';
import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/repository/zona_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

class ZonaRepositoryImpl implements ZonaRepository {
  final ZonaService _service;

  ZonaRepositoryImpl(this._service);

  @override
  Future<Resource<Zona>> createZona(CreateZonaRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [ZonaRepository] Creando zona: ${request.nombre}');
      }

      final result = await _service.createZona(request);

      if (kDebugMode) {
        if (result is Success<Zona>) {
          print('✅ [ZonaRepository] Zona creada exitosamente: ${result.data.nombre}');
        } else if (result is Error<Zona>) {
          print('❌ [ZonaRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaRepository] Excepción en createZona: $e');
      }
      return Error('Error inesperado al crear zona: $e');
    }
  }

  @override
  Future<Resource<List<Zona>>> getZonas() async {
    try {
      if (kDebugMode) {
        print('📦 [ZonaRepository] Obteniendo zonas...');
      }

      final result = await _service.getZonas();

      if (kDebugMode) {
        if (result is Success<List<Zona>>) {
          print('✅ [ZonaRepository] ${result.data.length} zonas obtenidas');
        } else if (result is Error<List<Zona>>) {
          print('❌ [ZonaRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaRepository] Excepción en getZonas: $e');
      }
      return Error('Error inesperado al obtener zonas: $e');
    }
  }

  @override
  Future<Resource<Zona>> getZonaById(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [ZonaRepository] Obteniendo zona con ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaRepository] Excepción en getZonaById: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<Zona>> updateZona(int id, CreateZonaRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [ZonaRepository] Actualizando zona ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaRepository] Excepción en updateZona: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<void>> deleteZona(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [ZonaRepository] Eliminando zona ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ZonaRepository] Excepción en deleteZona: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
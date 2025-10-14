import 'package:consumo_combustible/data/datasource/remote/service/sede_service.dart';
import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/repository/sede_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

class SedeRepositoryImpl implements SedeRepository {
  final SedeService _service;

  SedeRepositoryImpl(this._service);

  @override
  Future<Resource<Sede>> createSede(CreateSedeRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Creando sede: ${request.nombre}');
      }

      final result = await _service.createSede(request);

      if (kDebugMode) {
        if (result is Success<Sede>) {
          print('✅ [SedeRepository] Sede creada exitosamente: ${result.data.nombre}');
        } else if (result is Error<Sede>) {
          print('❌ [SedeRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en createSede: $e');
      }
      return Error('Error inesperado al crear sede: $e');
    }
  }

  @override
  Future<Resource<List<Sede>>> getSedes() async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Obteniendo sedes...');
      }

      final result = await _service.getSedes();

      if (kDebugMode) {
        if (result is Success<List<Sede>>) {
          print('✅ [SedeRepository] ${result.data.length} sedes obtenidas');
        } else if (result is Error<List<Sede>>) {
          print('❌ [SedeRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en getSedes: $e');
      }
      return Error('Error inesperado al obtener sedes: $e');
    }
  }

  @override
  Future<Resource<List<Sede>>> getSedesByZona(int zonaId) async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Obteniendo sedes de zona: $zonaId');
      }

      final result = await _service.getSedesByZona(zonaId);

      if (kDebugMode) {
        if (result is Success<List<Sede>>) {
          print('✅ [SedeRepository] ${result.data.length} sedes de zona $zonaId');
        } else if (result is Error<List<Sede>>) {
          print('❌ [SedeRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en getSedesByZona: $e');
      }
      return Error('Error inesperado al obtener sedes por zona: $e');
    }
  }

  @override
  Future<Resource<Sede>> getSedeById(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Obteniendo sede con ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en getSedeById: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<Sede>> updateSede(int id, CreateSedeRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Actualizando sede ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en updateSede: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<void>> deleteSede(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [SedeRepository] Eliminando sede ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [SedeRepository] Excepción en deleteSede: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
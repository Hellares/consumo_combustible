import 'package:consumo_combustible/data/datasource/remote/service/grifo_service.dart';
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

class GrifoRepositoryImpl implements GrifoRepository {
  final GrifoService _service;

  GrifoRepositoryImpl(this._service);

  @override
  Future<Resource<Grifo>> createGrifo(CreateGrifoRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Creando grifo: ${request.nombre}');
      }

      final result = await _service.createGrifo(request);

      if (kDebugMode) {
        if (result is Success<Grifo>) {
          print('✅ [GrifoRepository] Grifo creado: ${result.data.nombre}');
        } else if (result is Error<Grifo>) {
          print('❌ [GrifoRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en createGrifo: $e');
      }
      return Error('Error inesperado al crear grifo: $e');
    }
  }

  @override
  Future<Resource<List<Grifo>>> getGrifos() async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Obteniendo grifos...');
      }

      final result = await _service.getGrifos();

      if (kDebugMode) {
        if (result is Success<List<Grifo>>) {
          print('✅ [GrifoRepository] ${result.data.length} grifos obtenidos');
        } else if (result is Error<List<Grifo>>) {
          print('❌ [GrifoRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en getGrifos: $e');
      }
      return Error('Error inesperado al obtener grifos: $e');
    }
  }

  @override
  Future<Resource<List<Grifo>>> getGrifosBySede(int sedeId) async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Obteniendo grifos de sede: $sedeId');
      }

      final result = await _service.getGrifosBySede(sedeId);

      if (kDebugMode) {
        if (result is Success<List<Grifo>>) {
          print('✅ [GrifoRepository] ${result.data.length} grifos de sede $sedeId');
        } else if (result is Error<List<Grifo>>) {
          print('❌ [GrifoRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en getGrifosBySede: $e');
      }
      return Error('Error inesperado al obtener grifos por sede: $e');
    }
  }

  @override
  Future<Resource<Grifo>> getGrifoById(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Obteniendo grifo con ID: $id');
      }

      final result = await _service.getGrifoById(id);

      if (kDebugMode) {
        if (result is Success<Grifo>) {
          print('✅ [GrifoRepository] Grifo obtenido: ${result.data.nombre}');
        } else if (result is Error<Grifo>) {
          print('❌ [GrifoRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en getGrifoById: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<Grifo>> updateGrifo(int id, CreateGrifoRequest request) async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Actualizando grifo ID: $id');
      }

      final result = await _service.updateGrifo(id, request);

      if (kDebugMode) {
        if (result is Success<Grifo>) {
          print('✅ [GrifoRepository] Grifo actualizado: ${result.data.nombre}');
        } else if (result is Error<Grifo>) {
          print('❌ [GrifoRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en updateGrifo: $e');
      }
      return Error('Error inesperado al actualizar grifo: $e');
    }
  }

  @override
  Future<Resource<void>> deleteGrifo(int id) async {
    try {
      if (kDebugMode) {
        print('📦 [GrifoRepository] Eliminando grifo ID: $id');
      }

      // TODO: Implementar cuando el backend tenga el endpoint
      return Error('Método no implementado aún');
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GrifoRepository] Excepción en deleteGrifo: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}
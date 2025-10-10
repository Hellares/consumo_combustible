// lib/data/repository/archivo_repository_impl.dart

import 'dart:io';
import 'package:consumo_combustible/data/datasource/remote/service/archivo_service.dart';
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

class ArchivoRepositoryImpl implements ArchivoRepository {
  final ArchivoService _service;

  ArchivoRepositoryImpl(this._service);

  @override
  Future<Resource<List<TipoArchivo>>> getTiposArchivo() async {
    try {
      if (kDebugMode) {
        print('📦 [ArchivoRepository] Obteniendo tipos de archivo...');
      }
      
      final result = await _service.getTiposArchivo();
      
      // if (kDebugMode) {
      //   if (result is Success) {
      //     print('✅ [ArchivoRepository] ${result.data.length} tipos obtenidos');
      //   } else if (result is Error) {
      //     print('❌ [ArchivoRepository] Error: ${result.message}');
      //   }
      // }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ArchivoRepository] Excepción en getTiposArchivo: $e');
      }
      return Error('Error inesperado al obtener tipos de archivo: $e');
    }
  }

  @override
  Future<Resource<List<ArchivoTicket>>> uploadArchivos({
    required int ticketId,
    required int tipoArchivoId,
    required List<File> files,
    String? descripcion,
    int? orden,
    bool esPrincipal = false,
  }) async {
    try {
      if (kDebugMode) {
        print('📦 [ArchivoRepository] Subiendo ${files.length} archivo(s)...');
        print('   Ticket: $ticketId | Tipo: $tipoArchivoId');
      }
      
      final result = await _service.uploadArchivos(
        ticketId: ticketId,
        tipoArchivoId: tipoArchivoId,
        files: files,
        descripcion: descripcion,
        orden: orden,
        esPrincipal: esPrincipal,
      );
      
      // if (kDebugMode) {
      //   if (result is Success) {
      //     print('✅ [ArchivoRepository] ${result.data.length} archivo(s) subido(s)');
      //   } else if (result is Error) {
      //     print('❌ [ArchivoRepository] Error al subir: ${result.message}');
      //   }
      // }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ArchivoRepository] Excepción en uploadArchivos: $e');
      }
      return Error('Error inesperado al subir archivos: $e');
    }
  }

  @override
  Future<Resource<List<ArchivoTicket>>> getArchivosByTicket(int ticketId) async {
    try {
      if (kDebugMode) {
        print('📦 [ArchivoRepository] Obteniendo archivos del ticket $ticketId...');
      }
      
      final result = await _service.getArchivosByTicket(ticketId);
      
      // if (kDebugMode) {
      //   if (result is Success) {
      //     print('✅ [ArchivoRepository] ${result.data.length} archivo(s) encontrado(s)');
      //   } else if (result is Error) {
      //     print('❌ [ArchivoRepository] Error: ${result.message}');
      //   }
      // }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ArchivoRepository] Excepción en getArchivosByTicket: $e');
      }
      return Error('Error inesperado al obtener archivos: $e');
    }
  }

  @override
  Future<Resource<void>> deleteArchivo(int archivoId) async {
    try {
      if (kDebugMode) {
        print('📦 [ArchivoRepository] Eliminando archivo $archivoId...');
      }
      
      final result = await _service.deleteArchivo(archivoId);
      
      if (kDebugMode) {
        if (result is Success) {
          print('✅ [ArchivoRepository] Archivo eliminado exitosamente');
        } else if (result is Error) {
          print('❌ [ArchivoRepository] Error al eliminar: ${result.message}');
        }
      }
      
      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ArchivoRepository] Excepción en deleteArchivo: $e');
      }
      return Error('Error inesperado al eliminar archivo: $e');
    }
  }
}
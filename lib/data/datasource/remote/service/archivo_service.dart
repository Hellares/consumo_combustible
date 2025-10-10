// lib/data/datasource/remote/service/archivo_service.dart

import 'dart:io';
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ArchivoService {
  final Dio _dio;

  ArchivoService(this._dio);

  // Obtener tipos de archivo disponibles
  Future<Resource<List<TipoArchivo>>> getTiposArchivo() async {
    try {
      if (kDebugMode) {
        print('📋 [ArchivoService] Obteniendo tipos de archivo...');
      }

      final response = await _dio.get('/api/archivos/tipos');

      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> tiposJson = data['data'] as List;
          final tipos = tiposJson
              .map((json) => TipoArchivo.fromJson(json))
              .where((tipo) => tipo.activo)
              .toList();

          if (kDebugMode) {
            print('✅ ${tipos.length} tipos de archivo cargados');
          }

          return Success(tipos);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} al obtener tipos de archivo');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getTiposArchivo: ${e.message}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en getTiposArchivo: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // Subir archivos (multipart/form-data)
  Future<Resource<List<ArchivoTicket>>> uploadArchivos({
    required int ticketId,
    required int tipoArchivoId,
    required List<File> files,
    String? descripcion,
    int? orden,
    bool esPrincipal = false,
  }) async {
    try {
      if (files.isEmpty) {
        return Error('Debe seleccionar al menos un archivo');
      }

      if (kDebugMode) {
        print('📤 [ArchivoService] Subiendo ${files.length} archivo(s)...');
        print('   Ticket ID: $ticketId');
        print('   Tipo Archivo ID: $tipoArchivoId');
      }

      // Crear FormData
      final formData = FormData();

      // Agregar archivos
      for (var file in files) {
        final fileName = file.path.split('/').last;
        final mimeType = _getMimeType(fileName);

        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            ),
          ),
        );

        if (kDebugMode) {
          print('   📎 Archivo: $fileName (${mimeType})');
        }
      }

      // Agregar campos del formulario
      formData.fields.addAll([
        MapEntry('ticketId', ticketId.toString()),
        MapEntry('tipoArchivoId', tipoArchivoId.toString()),
        if (descripcion != null) MapEntry('descripcion', descripcion),
        if (orden != null) MapEntry('orden', orden.toString()),
        MapEntry('esPrincipal', esPrincipal.toString()),
      ]);

      // Realizar petición
      final response = await _dio.post(
        '/api/archivos/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> archivosJson = data['data'] as List;
          final archivos = archivosJson
              .map((json) => ArchivoTicket.fromJson(json))
              .toList();

          if (kDebugMode) {
            print('✅ ${archivos.length} archivo(s) subido(s) exitosamente');
          }

          return Success(archivos);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} al subir archivos');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en uploadArchivos: ${e.message}');
        print('   Response: ${e.response?.data}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en uploadArchivos: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // Obtener archivos de un ticket
  Future<Resource<List<ArchivoTicket>>> getArchivosByTicket(int ticketId) async {
    try {
      if (kDebugMode) {
        print('📂 [ArchivoService] Obteniendo archivos del ticket $ticketId...');
      }

      final response = await _dio.get('/api/archivos/ticket/$ticketId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> archivosJson = data['data'] as List;
          final archivos = archivosJson
              .map((json) => ArchivoTicket.fromJson(json))
              .toList();

          if (kDebugMode) {
            print('✅ ${archivos.length} archivo(s) encontrado(s)');
          }

          return Success(archivos);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} al obtener archivos');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getArchivosByTicket: ${e.message}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en getArchivosByTicket: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // Eliminar archivo
  Future<Resource<void>> deleteArchivo(int archivoId) async {
    try {
      if (kDebugMode) {
        print('🗑️ [ArchivoService] Eliminando archivo $archivoId...');
      }

      final response = await _dio.delete('/api/archivos/$archivoId');

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Archivo eliminado exitosamente');
        }
        return Success(null);
      }

      return Error('Error ${response.statusCode} al eliminar archivo');
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en deleteArchivo: ${e.message}');
      }
      return Error(_handleDioError(e));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en deleteArchivo: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // Helper: Determinar MIME type
  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  // Helper: Manejar errores de Dio
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de respuesta agotado';
    } else if (e.response?.statusCode == 413) {
      return 'Archivo(s) demasiado grande(s)';
    } else if (e.response?.statusCode == 415) {
      return 'Tipo de archivo no permitido';
    } else if (e.response?.statusCode == 404) {
      return 'Recurso no encontrado';
    } else if (e.response?.statusCode == 500) {
      return 'Error en el servidor';
    }

    return e.response?.data['message'] ?? 'Error de conexión';
  }
}
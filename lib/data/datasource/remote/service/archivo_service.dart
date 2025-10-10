// lib/data/datasource/remote/service/archivo_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class ArchivoService {
  final Dio _dio;
  final FastStorageService _storage;
  static const String _tiposArchivoCacheKey = 'tipos_archivo_cache';

  ArchivoService(this._dio, this._storage);

  // Obtener tipos de archivo disponibles (con caché)
  Future<Resource<List<TipoArchivo>>> getTiposArchivo({bool forceRefresh = false}) async {
    try {
      // 1. Intentar obtener desde caché (si no es refresh forzado)
      if (!forceRefresh) {
        final cachedData = await _storage.read(_tiposArchivoCacheKey);
        if (cachedData != null) {
          try {
            final List<dynamic> tiposJson = jsonDecode(cachedData) as List;
            final tipos = tiposJson
                .map((json) => TipoArchivo.fromJson(json))
                .where((tipo) => tipo.activo)
                .toList();

            if (kDebugMode) {
              print('⚡ [ArchivoService] ${tipos.length} tipos cargados desde CACHÉ');
            }

            return Success(tipos);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error al decodificar caché, obteniendo de servidor...');
            }
          }
        }
      }

      // 2. Obtener desde servidor
      if (kDebugMode) {
        print('📋 [ArchivoService] Obteniendo tipos de archivo desde servidor...');
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

          // 3. Guardar en caché para futuras consultas
          await _storage.writeAsync(_tiposArchivoCacheKey, jsonEncode(tiposJson));

          if (kDebugMode) {
            print('✅ ${tipos.length} tipos de archivo cargados y cacheados');
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

          // ✅ Invalidar caché del ticket después de subir
          final cacheKey = 'archivos_ticket_$ticketId';
          await _storage.delete(cacheKey);

          if (kDebugMode) {
            print('✅ ${archivos.length} archivo(s) subido(s) exitosamente');
            print('🗑️ Caché invalidado para ticket $ticketId');
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

  // Obtener archivos de un ticket (con caché)
  Future<Resource<List<ArchivoTicket>>> getArchivosByTicket(int ticketId, {bool forceRefresh = false}) async {
    try {
      final cacheKey = 'archivos_ticket_$ticketId';

      // 1. Intentar obtener desde caché (si no es refresh forzado)
      if (!forceRefresh) {
        final cachedData = await _storage.read(cacheKey);
        if (cachedData != null) {
          try {
            final List<dynamic> archivosJson = jsonDecode(cachedData) as List;
            final archivos = archivosJson
                .map((json) => ArchivoTicket.fromJson(json))
                .toList();

            if (kDebugMode) {
              print('⚡ [ArchivoService] ${archivos.length} archivo(s) cargados desde CACHÉ (ticket $ticketId)');
            }

            return Success(archivos);
          } catch (e) {
            if (kDebugMode) {
              print('⚠️ Error al decodificar caché, obteniendo de servidor...');
            }
          }
        }
      }

      // 2. Obtener desde servidor
      if (kDebugMode) {
        print('📂 [ArchivoService] Obteniendo archivos del ticket $ticketId desde servidor...');
      }

      final response = await _dio.get('/api/archivos/ticket/$ticketId');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> archivosJson = data['data'] as List;
          final archivos = archivosJson
              .map((json) => ArchivoTicket.fromJson(json))
              .toList();

          // 3. Guardar en caché para futuras consultas
          await _storage.writeAsync(cacheKey, jsonEncode(archivosJson));

          if (kDebugMode) {
            print('✅ ${archivos.length} archivo(s) encontrado(s) y cacheados');
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
  Future<Resource<void>> deleteArchivo(int archivoId, int ticketId) async {
    try {
      if (kDebugMode) {
        print('🗑️ [ArchivoService] Eliminando archivo $archivoId...');
      }

      final response = await _dio.delete('/api/archivos/$archivoId');

      if (response.statusCode == 200) {
        // ✅ Invalidar caché del ticket después de eliminar
        final cacheKey = 'archivos_ticket_$ticketId';
        await _storage.delete(cacheKey);

        if (kDebugMode) {
          print('✅ Archivo eliminado exitosamente');
          print('🗑️ Caché invalidado para ticket $ticketId');
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
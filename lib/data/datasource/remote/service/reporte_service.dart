// lib/data/api/reporte_service.dart

import 'dart:io';
import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Servicio para la API de reportes
/// Maneja todas las peticiones HTTP relacionadas con reportes
class ReporteService {
  final Dio _dio;

  ReporteService(this._dio);

  /// Exportar reporte y descargar archivo (Excel, CSV)
  /// 
  /// Este método descarga el archivo binario del servidor y lo guarda localmente
  Future<Resource<DescargaArchivoResponse>> exportarReporte(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteService] Exportando reporte...');
        print('   Tipo: ${filtros.tipoReporte}');
        print('   Formato: ${filtros.formato}');
        print('   Filtros: ${filtros.toQueryParameters()}');
      }

      // 1. Construir URL base según el tipo de reporte
      final String endpoint = _getEndpointPorTipo(filtros.tipoReporte);
      
      // 2. Obtener directorio de descargas del dispositivo
      final directory = await _getDownloadDirectory();
      
      // 3. Generar nombre del archivo
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final String extension = _getExtension(filtros.formato);
      final String nombreArchivo = 
          'Reporte_${filtros.tipoReporte.value}_$timestamp$extension';
      final String rutaCompleta = '${directory.path}/$nombreArchivo';

      if (kDebugMode) {
        print('📁 Guardando en: $rutaCompleta');
      }

      // 4. Realizar descarga con Dio
      final response = await _dio.get(
        endpoint,
        queryParameters: filtros.toQueryParameters(),
        options: Options(
          responseType: ResponseType.bytes, // ✅ IMPORTANTE: Recibir bytes
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
          // Timeouts más largos para descargas grandes
          receiveTimeout: const Duration(minutes: 3),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      if (kDebugMode) {
        print('📡 Status: ${response.statusCode}');
        print('📦 Tamaño descargado: ${response.data.length} bytes');
      }

      // 5. Validar respuesta
      if (response.statusCode != 200) {
        return Error('Error ${response.statusCode} al descargar el reporte');
      }

      // 6. Guardar archivo en el dispositivo
      final File archivo = File(rutaCompleta);
      await archivo.writeAsBytes(response.data);

      if (kDebugMode) {
        print('✅ Archivo guardado exitosamente');
      }

      // 7. Retornar respuesta de éxito
      return Success(
        DescargaArchivoResponse.exitosa(
          rutaArchivo: rutaCompleta,
          nombreArchivo: nombreArchivo,
          tamanioBytes: response.data.length,
          formato: filtros.formato,
        ),
      );
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] DioException: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }
      return Error(_handleDioError(e));
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] Error inesperado: $e');
      }
      return Error('Error al descargar el reporte: $e');
    }
  }

  /// Obtener datos del reporte en formato JSON (sin descarga)
  /// 
  /// Útil para mostrar datos en la UI o hacer gráficos
  Future<Resource<ReporteResponse>> obtenerDatosReporte(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteService] Obteniendo datos del reporte...');
        print('   Tipo: ${filtros.tipoReporte}');
        print('   Filtros: ${filtros.toQueryParameters()}');
      }

      final response = await _dio.get(
        '/api/reportes/datos',
        queryParameters: filtros.toQueryParameters(),
        options: Options(
          responseType: ResponseType.json, // ✅ JSON response
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('✅ Datos obtenidos: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final reporteResponse = ReporteResponse.fromJson(data);
          
          if (kDebugMode) {
            print('📦 Total registros: ${reporteResponse.totalRegistros}');
          }

          return Success(reporteResponse);
        } else {
          return Error(data['message'] ?? 'Error al obtener datos');
        }
      }

      return Error('Error ${response.statusCode} al obtener datos');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] DioException: ${e.message}');
      }
      return Error(_handleDioError(e));
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Obtener resumen de datos disponibles
  Future<Resource<ResumenReporteResponse>> obtenerResumen() async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteService] Obteniendo resumen...');
      }

      final response = await _dio.get(
        '/api/reportes/resumen',
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (kDebugMode) {
        print('✅ Resumen obtenido: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true) {
          final resumen = ResumenReporteResponse.fromJson(data);
          
          if (kDebugMode) {
            print('📦 Total abastecimientos: ${resumen.resumen.totalAbastecimientos}');
            print('📦 Total unidades: ${resumen.resumen.totalUnidades}');
          }

          return Success(resumen);
        } else {
          return Error(data['message'] ?? 'Error al obtener resumen');
        }
      }

      return Error('Error ${response.statusCode} al obtener resumen');
      
    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] DioException: ${e.message}');
      }
      return Error(_handleDioError(e));
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteService] Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  // ==================== MÉTODOS PRIVADOS HELPERS ====================

  /// Obtener endpoint según el tipo de reporte
  String _getEndpointPorTipo(TipoReporte tipo) {
    switch (tipo) {
      case TipoReporte.abastecimientos:
        return '/api/reportes/exportar/abastecimientos';
      case TipoReporte.consumoPorUnidad:
        return '/api/reportes/exportar/consumo-por-unidad';
      case TipoReporte.estadisticasGrifo:
        return '/api/reportes/exportar/estadisticas-grifo';
      case TipoReporte.rendimiento:
        return '/api/reportes/exportar/rendimiento';
    }
  }

  /// Obtener extensión del archivo según el formato
  String _getExtension(FormatoExportacion formato) {
    switch (formato) {
      case FormatoExportacion.excel:
        return '.xlsx';
      case FormatoExportacion.csv:
        return '.csv';
      case FormatoExportacion.json:
        return '.json';
    }
  }

  /// Obtener directorio de descargas según la plataforma
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // Android: Solicitar permisos y usar directorio de descargas público
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Permisos de almacenamiento denegados. No se puede guardar el archivo.');
      }

      // Intentar primero con getExternalStorageDirectory() para mejor compatibilidad
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final reportesDir = Directory('${directory.path}/Download/Reportes');
          if (!await reportesDir.exists()) {
            await reportesDir.create(recursive: true);
          }
          return reportesDir;
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error obteniendo directorio externo: $e');
        }
      }

      // Fallback: ruta directa (requiere permisos)
      final directory = Directory('/storage/emulated/0/Download/Reportes');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory;
    } else if (Platform.isIOS) {
      // iOS: Usar directorio de documentos de la app
      final directory = await getApplicationDocumentsDirectory();
      final reportesDir = Directory('${directory.path}/Reportes');
      if (!await reportesDir.exists()) {
        await reportesDir.create(recursive: true);
      }
      return reportesDir;
    } else {
      // Otras plataformas (Windows, macOS, Linux)
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final reportesDir = Directory('${directory.path}/Reportes');
        if (!await reportesDir.exists()) {
          await reportesDir.create(recursive: true);
        }
        return reportesDir;
      }

      // Fallback: directorio de documentos
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Manejar errores de Dio de forma consistente
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tiempo de conexión agotado. Verifica tu internet.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. El reporte es muy grande.';
    } else if (e.type == DioExceptionType.sendTimeout) {
      return 'Tiempo de envío agotado.';
    } else if (e.response?.statusCode == 400) {
      return e.response?.data['message'] ?? 
             'Parámetros de filtros inválidos';
    } else if (e.response?.statusCode == 401) {
      return 'No autorizado. Inicia sesión nuevamente.';
    } else if (e.response?.statusCode == 404) {
      return 'No se encontraron datos para los filtros especificados';
    } else if (e.response?.statusCode == 500) {
      return 'Error en el servidor al generar el reporte';
    }

    return e.response?.data['message'] ?? 
           'Error de conexión al descargar el reporte';
  }
}
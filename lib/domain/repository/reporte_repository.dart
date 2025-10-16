// lib/domain/repositories/reporte_repository.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Interfaz del repositorio de reportes
/// Define el contrato que debe cumplir la implementación en la capa data
abstract class ReporteRepository {
  
  /// Exportar reporte y descargar archivo (Excel, CSV)
  /// 
  /// Descarga el archivo en el dispositivo y retorna la metadata de la descarga
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados al reporte
  /// 
  /// Retorna:
  /// - [Resource<DescargaArchivoResponse>] con información de la descarga
  /// 
  /// Ejemplo:
  /// ```dart
  /// final filtros = FiltrosReporte(
  ///   formato: FormatoExportacion.excel,
  ///   fechaInicio: DateTime(2025, 1, 1),
  ///   fechaFin: DateTime(2025, 12, 31),
  /// );
  /// 
  /// final resultado = await repository.exportarReporte(filtros);
  /// 
  /// if (resultado is Success) {
  ///   print('Archivo guardado en: ${resultado.data.rutaArchivo}');
  /// }
  /// ```
  Future<Resource<DescargaArchivoResponse>> exportarReporte(
    FiltrosReporte filtros,
  );

  /// Obtener datos del reporte en formato JSON (sin descarga)
  /// 
  /// Útil para mostrar datos en la UI, hacer gráficos, etc.
  /// NO descarga ningún archivo.
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados al reporte
  /// 
  /// Retorna:
  /// - [Resource<ReporteResponse>] con los datos en JSON
  /// 
  /// Ejemplo:
  /// ```dart
  /// final filtros = FiltrosReporte(
  ///   tipoReporte: TipoReporte.consumoPorUnidad,
  ///   zonaId: 1,
  /// );
  /// 
  /// final resultado = await repository.obtenerDatosReporte(filtros);
  /// 
  /// if (resultado is Success) {
  ///   print('Total registros: ${resultado.data.totalRegistros}');
  ///   final datos = resultado.data.datos; // List<Map<String, dynamic>>
  /// }
  /// ```
  Future<Resource<ReporteResponse>> obtenerDatosReporte(
    FiltrosReporte filtros,
  );

  /// Obtener resumen general de datos disponibles
  /// 
  /// Retorna información sobre:
  /// - Total de abastecimientos
  /// - Total de unidades
  /// - Total de grifos
  /// - Fecha del primer y último registro
  /// - Tipos de reportes disponibles
  /// - Formatos de exportación disponibles
  /// 
  /// Retorna:
  /// - [Resource<ResumenReporteResponse>] con el resumen
  /// 
  /// Ejemplo:
  /// ```dart
  /// final resultado = await repository.obtenerResumen();
  /// 
  /// if (resultado is Success) {
  ///   final resumen = resultado.data.resumen;
  ///   print('Total abastecimientos: ${resumen.totalAbastecimientos}');
  ///   print('Periodo: ${resumen.fechaPrimerRegistro} - ${resumen.fechaUltimoRegistro}');
  /// }
  /// ```
  Future<Resource<ResumenReporteResponse>> obtenerResumen();

  /// Exportar reporte de abastecimientos (endpoint específico)
  /// 
  /// Atajo directo para el reporte más común.
  /// Internamente configura [tipoReporte] como [TipoReporte.abastecimientos]
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados (el tipoReporte se sobrescribe)
  /// 
  /// Retorna:
  /// - [Resource<DescargaArchivoResponse>] con información de la descarga
  Future<Resource<DescargaArchivoResponse>> exportarAbastecimientos(
    FiltrosReporte filtros,
  );

  /// Exportar reporte de consumo por unidad
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados (el tipoReporte se sobrescribe)
  /// 
  /// Retorna:
  /// - [Resource<DescargaArchivoResponse>] con información de la descarga
  Future<Resource<DescargaArchivoResponse>> exportarConsumoPorUnidad(
    FiltrosReporte filtros,
  );

  /// Exportar reporte de estadísticas por grifo
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados (el tipoReporte se sobrescribe)
  /// 
  /// Retorna:
  /// - [Resource<DescargaArchivoResponse>] con información de la descarga
  Future<Resource<DescargaArchivoResponse>> exportarEstadisticasGrifo(
    FiltrosReporte filtros,
  );

  /// Exportar reporte de rendimiento
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados (el tipoReporte se sobrescribe)
  /// 
  /// Retorna:
  /// - [Resource<DescargaArchivoResponse>] con información de la descarga
  Future<Resource<DescargaArchivoResponse>> exportarRendimiento(
    FiltrosReporte filtros,
  );
}
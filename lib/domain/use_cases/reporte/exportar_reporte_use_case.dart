// lib/domain/use_cases/reporte/exportar_reporte_use_case.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/repository/reporte_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Caso de uso para exportar un reporte y descargarlo
/// 
/// Este caso de uso maneja la exportación de reportes en formato
/// Excel, CSV o JSON, descargando el archivo al dispositivo.
class ExportarReporteUseCase {
  final ReporteRepository _repository;

  ExportarReporteUseCase(this._repository);

  /// Ejecutar la exportación del reporte
  /// 
  /// Parámetros:
  /// - [filtros]: Filtros aplicados al reporte (fechas, zona, etc.)
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
  /// final resultado = await exportarReporteUseCase.run(filtros);
  /// 
  /// if (resultado is Success) {
  ///   print('Archivo guardado en: ${resultado.data.rutaArchivo}');
  /// } else if (resultado is Error) {
  ///   print('Error: ${resultado.message}');
  /// }
  /// ```
  Future<Resource<DescargaArchivoResponse>> run(FiltrosReporte filtros) {
    return _repository.exportarReporte(filtros);
  }
}
// lib/domain/use_cases/reporte/obtener_datos_reporte_use_case.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/repository/reporte_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Caso de uso para obtener datos de un reporte en formato JSON
/// 
/// Este caso de uso NO descarga archivos, solo retorna los datos
/// en JSON para ser usados en la UI (tablas, gráficos, etc.)
class ObtenerDatosReporteUseCase {
  final ReporteRepository _repository;

  ObtenerDatosReporteUseCase(this._repository);

  /// Ejecutar la consulta de datos del reporte
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
  /// final resultado = await obtenerDatosReporteUseCase.run(filtros);
  /// 
  /// if (resultado is Success) {
  ///   final datos = resultado.data.datos; // List<Map<String, dynamic>>
  ///   print('Total registros: ${resultado.data.totalRegistros}');
  /// }
  /// ```
  Future<Resource<ReporteResponse>> run(FiltrosReporte filtros) {
    return _repository.obtenerDatosReporte(filtros);
  }
}
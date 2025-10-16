// lib/domain/use_cases/reporte/obtener_resumen_use_case.dart

import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/repository/reporte_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Caso de uso para obtener el resumen general del sistema
/// 
/// Retorna información sobre:
/// - Total de abastecimientos
/// - Total de unidades
/// - Total de grifos
/// - Fecha del primer y último registro
/// - Tipos de reportes disponibles
class ObtenerResumenUseCase {
  final ReporteRepository _repository;

  ObtenerResumenUseCase(this._repository);

  /// Ejecutar la consulta del resumen
  /// 
  /// No requiere parámetros.
  /// 
  /// Retorna:
  /// - [Resource<ResumenReporteResponse>] con el resumen
  /// 
  /// Ejemplo:
  /// ```dart
  /// final resultado = await obtenerResumenUseCase.run();
  /// 
  /// if (resultado is Success) {
  ///   final resumen = resultado.data.resumen;
  ///   print('Total abastecimientos: ${resumen.totalAbastecimientos}');
  ///   print('Periodo: ${resumen.fechaPrimerRegistro} - ${resumen.fechaUltimoRegistro}');
  /// }
  /// ```
  Future<Resource<ResumenReporteResponse>> run() {
    return _repository.obtenerResumen();
  }
}
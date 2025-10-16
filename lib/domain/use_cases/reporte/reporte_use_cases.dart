// lib/domain/use_cases/reporte/reporte_use_cases.dart

import 'package:consumo_combustible/domain/use_cases/reporte/exportar_reporte_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/reporte/obtener_datos_reporte_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/reporte/obtener_resumen_use_case.dart';

/// Wrapper que agrupa todos los casos de uso de reportes
/// 
/// Facilita la inyección de dependencias y el acceso a los casos de uso
/// desde el BLoC o cualquier otra capa de presentación.
/// 
/// Uso:
/// ```dart
/// final reporteUseCases = locator<ReporteUseCases>();
/// 
/// // Exportar reporte
/// final resultado = await reporteUseCases.exportarReporte.run(filtros);
/// 
/// // Obtener datos
/// final datos = await reporteUseCases.obtenerDatos.run(filtros);
/// 
/// // Obtener resumen
/// final resumen = await reporteUseCases.obtenerResumen.run();
/// ```
class ReporteUseCases {
  final ExportarReporteUseCase exportarReporte;
  final ObtenerDatosReporteUseCase obtenerDatos;
  final ObtenerResumenUseCase obtenerResumen;

  ReporteUseCases({
    required this.exportarReporte,
    required this.obtenerDatos,
    required this.obtenerResumen,
  });
}
// lib/presentation/page/reportes/bloc/reporte_state.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

/// Estado del BLoC de Reportes
class ReporteState extends Equatable {
  // === FILTROS ACTUALES ===
  final FiltrosReporte filtros;

  // === RESPONSES DE LAS OPERACIONES (NULLABLE como en tu patrón) ===
  final Resource? exportarResponse;
  final Resource? datosResponse;
  final Resource? resumenResponse;

  // === DATOS CACHEADOS ===
  final ResumenReporteResponse? resumen; // Resumen del sistema

  const ReporteState({
    this.filtros = const FiltrosReporte(),
    this.exportarResponse,        // ✅ Sin tipo genérico, nullable
    this.datosResponse,            // ✅ Sin tipo genérico, nullable
    this.resumenResponse,          // ✅ Sin tipo genérico, nullable
    this.resumen,
  });

  /// CopyWith para actualizar el estado
  ReporteState copyWith({
    FiltrosReporte? filtros,
    Resource? exportarResponse,
    Resource? datosResponse,
    Resource? resumenResponse,
    ResumenReporteResponse? resumen,
  }) {
    return ReporteState(
      filtros: filtros ?? this.filtros,
      exportarResponse: exportarResponse ?? this.exportarResponse,
      datosResponse: datosResponse ?? this.datosResponse,
      resumenResponse: resumenResponse ?? this.resumenResponse,
      resumen: resumen ?? this.resumen,
    );
  }

  /// Resetear todas las respuestas (mantener filtros y resumen)
  ReporteState resetResponses() {
    return ReporteState(
      filtros: filtros,
      resumen: resumen,
      exportarResponse: null,  // ✅ null en lugar de Initial()
      datosResponse: null,
      resumenResponse: null,
    );
  }

  /// Limpiar mensajes (útil después de mostrar snackbars)
  ReporteState clearMessages() {
    return copyWith(
      exportarResponse: null,  // ✅ null en lugar de Initial()
      datosResponse: null,
    );
  }

  @override
  List<Object?> get props => [
        filtros,
        exportarResponse,
        datosResponse,
        resumenResponse,
        resumen,
      ];
}
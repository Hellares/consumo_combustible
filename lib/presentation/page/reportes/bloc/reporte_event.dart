// lib/presentation/page/reportes/bloc/reporte_event.dart

import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:equatable/equatable.dart';

/// Eventos del BLoC de Reportes
abstract class ReporteEvent extends Equatable {
  const ReporteEvent();

  @override
  List<Object?> get props => [];
}

/// Evento: Exportar reporte y descargar archivo
class ExportarReporteEvent extends ReporteEvent {
  final FiltrosReporte filtros;

  const ExportarReporteEvent(this.filtros);

  @override
  List<Object?> get props => [filtros];
}

/// Evento: Obtener datos del reporte en JSON (sin descarga)
class ObtenerDatosReporteEvent extends ReporteEvent {
  final FiltrosReporte filtros;

  const ObtenerDatosReporteEvent(this.filtros);

  @override
  List<Object?> get props => [filtros];
}

/// Evento: Obtener resumen general del sistema
class ObtenerResumenEvent extends ReporteEvent {
  const ObtenerResumenEvent();
}

/// Evento: Actualizar filtros
class ActualizarFiltrosEvent extends ReporteEvent {
  final FiltrosReporte filtros;

  const ActualizarFiltrosEvent(this.filtros);

  @override
  List<Object?> get props => [filtros];
}

/// Evento: Limpiar filtros (mantener solo tipo y formato)
class LimpiarFiltrosEvent extends ReporteEvent {
  const LimpiarFiltrosEvent();
}

/// Evento: Resetear estado completo del BLoC
class ResetReporteStateEvent extends ReporteEvent {
  const ResetReporteStateEvent();
}

/// Evento: Limpiar mensajes de error/éxito
class ClearReporteMessagesEvent extends ReporteEvent {
  const ClearReporteMessagesEvent();
}
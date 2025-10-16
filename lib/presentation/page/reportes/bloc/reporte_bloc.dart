// lib/presentation/page/reportes/bloc/reporte_bloc.dart

import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/use_cases/reporte/reporte_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_event.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// BLoC para gestionar el estado de los reportes
class ReporteBloc extends Bloc<ReporteEvent, ReporteState> {
  final ReporteUseCases _useCases;

  ReporteBloc(this._useCases) : super(const ReporteState()) {
    on<ExportarReporteEvent>(_onExportarReporte);
    on<ObtenerDatosReporteEvent>(_onObtenerDatosReporte);
    on<ObtenerResumenEvent>(_onObtenerResumen);
    on<ActualizarFiltrosEvent>(_onActualizarFiltros);
    on<LimpiarFiltrosEvent>(_onLimpiarFiltros);
    on<ResetReporteStateEvent>(_onResetState);
    on<ClearReporteMessagesEvent>(_onClearMessages);
  }

  /// Exportar reporte y descargar archivo
  Future<void> _onExportarReporte(
    ExportarReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteBloc] Exportando reporte...');
        print('   Tipo: ${event.filtros.tipoReporte}');
        print('   Formato: ${event.filtros.formato}');
      }

      emit(state.copyWith(
        exportarResponse: Loading(),  // ✅ Sin tipo genérico
      ));

      final result = await _useCases.exportarReporte.run(event.filtros);

      if (result is Success<DescargaArchivoResponse>) {
        if (kDebugMode) {
          print('✅ [ReporteBloc] Reporte exportado exitosamente');
          print('   Archivo: ${result.data.nombreArchivo}');
          print('   Tamaño: ${result.data.tamanioFormateado}');
          print('   Ruta: ${result.data.rutaArchivo}');
        }

        emit(state.copyWith(exportarResponse: result));
      } else if (result is Error<DescargaArchivoResponse>) {
        if (kDebugMode) {
          print('❌ [ReporteBloc] Error al exportar: ${result.message}');
        }

        emit(state.copyWith(exportarResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteBloc] Exception en exportar: $e');
      }

      emit(state.copyWith(
        exportarResponse: Error('Error inesperado al exportar: $e'),
      ));
    }
  }

  /// Obtener datos del reporte en JSON
  Future<void> _onObtenerDatosReporte(
    ObtenerDatosReporteEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteBloc] Obteniendo datos del reporte...');
        print('   Tipo: ${event.filtros.tipoReporte}');
      }

      emit(state.copyWith(
        datosResponse: Loading(),  // ✅ Sin tipo genérico
      ));

      final result = await _useCases.obtenerDatos.run(event.filtros);

      if (result is Success<ReporteResponse>) {
        if (kDebugMode) {
          print('✅ [ReporteBloc] Datos obtenidos');
          print('   Total registros: ${result.data.totalRegistros}');
        }

        emit(state.copyWith(datosResponse: result));
      } else if (result is Error<ReporteResponse>) {
        if (kDebugMode) {
          print('❌ [ReporteBloc] Error al obtener datos: ${result.message}');
        }

        emit(state.copyWith(datosResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteBloc] Exception en obtener datos: $e');
      }

      emit(state.copyWith(
        datosResponse: Error('Error inesperado al obtener datos: $e'),
      ));
    }
  }

  /// Obtener resumen general del sistema
  Future<void> _onObtenerResumen(
    ObtenerResumenEvent event,
    Emitter<ReporteState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [ReporteBloc] Obteniendo resumen...');
      }

      emit(state.copyWith(
        resumenResponse: Loading(),  // ✅ Sin tipo genérico
      ));

      final result = await _useCases.obtenerResumen.run();

      if (result is Success<ResumenReporteResponse>) {
        if (kDebugMode) {
          print('✅ [ReporteBloc] Resumen obtenido');
          print('   Total abastecimientos: ${result.data.resumen.totalAbastecimientos}');
          print('   Total unidades: ${result.data.resumen.totalUnidades}');
          print('   Total grifos: ${result.data.resumen.totalGrifos}');
        }

        emit(state.copyWith(
          resumenResponse: result,
          resumen: result.data,
        ));
      } else if (result is Error<ResumenReporteResponse>) {
        if (kDebugMode) {
          print('❌ [ReporteBloc] Error al obtener resumen: ${result.message}');
        }

        emit(state.copyWith(resumenResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteBloc] Exception en obtener resumen: $e');
      }

      emit(state.copyWith(
        resumenResponse: Error('Error inesperado al obtener resumen: $e'),
      ));
    }
  }

  /// Actualizar filtros
  void _onActualizarFiltros(
    ActualizarFiltrosEvent event,
    Emitter<ReporteState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [ReporteBloc] Actualizando filtros');
      print('   Nuevos filtros: ${event.filtros}');
    }

    emit(state.copyWith(filtros: event.filtros));
  }

  /// Limpiar filtros (mantener solo tipo y formato)
  void _onLimpiarFiltros(
    LimpiarFiltrosEvent event,
    Emitter<ReporteState> emit,
  ) {
    if (kDebugMode) {
      print('🧹 [ReporteBloc] Limpiando filtros');
    }

    final filtrosLimpios = state.filtros.limpiar();
    emit(state.copyWith(filtros: filtrosLimpios));
  }

  /// Resetear estado completo
  void _onResetState(
    ResetReporteStateEvent event,
    Emitter<ReporteState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [ReporteBloc] Reseteando estado completo');
    }

    emit(const ReporteState());
  }

  /// Limpiar mensajes
  void _onClearMessages(
    ClearReporteMessagesEvent event,
    Emitter<ReporteState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [ReporteBloc] Limpiando mensajes');
    }

    emit(state.clearMessages());
  }
}
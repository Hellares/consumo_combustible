import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/detalle_abastecimiento_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_event.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetalleAbastecimientoBloc extends Bloc<DetalleAbastecimientoEvent, DetalleAbastecimientoState> {
  final DetalleAbastecimientoUseCases useCases;

  DetalleAbastecimientoBloc(this.useCases) : super(const DetalleAbastecimientoState()) {
    on<LoadDetallesAbastecimiento>(_onLoadDetallesAbastecimiento);
    on<LoadMoreDetalles>(_onLoadMoreDetalles);
    on<ActualizarDetalleEvent>(_onActualizarDetalle);
    on<ConcluirDetalleEvent>(_onConcluirDetalle);
    on<ResetDetallesState>(_onResetDetallesState);
  }

  Future<void> _onLoadDetallesAbastecimiento(
    LoadDetallesAbastecimiento event,
    Emitter<DetalleAbastecimientoState> emit,
  ) async {
    if (kDebugMode) {
      print('📋 [DetalleAbastecimientoBloc] Cargando detalles del grifo: ${event.grifoId}');
    }

    emit(state.copyWith(
      detallesResponse: Loading<Map<String, dynamic>>(),
      currentGrifoId: event.grifoId,
      currentPage: event.page,
    ));

    final response = await useCases.getDetallesAbastecimiento.run(
      grifoId: event.grifoId,
      page: event.page,
      pageSize: event.pageSize,
    );

    if (response is Success<Map<String, dynamic>>) {
      final data = response.data;
      final detalles = data['detalles'] as List<DetalleAbastecimiento>;
      final meta = data['meta'] as DetalleAbastecimientoMeta;

      if (kDebugMode) {
        print('✅ [DetalleAbastecimientoBloc] ${detalles.length} detalles cargados (Total: ${meta.total})');
      }

      emit(state.copyWith(
        detallesResponse: response,
        detalles: detalles,
        meta: meta,
      ));
    } else if (response is Error<Map<String, dynamic>>) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoBloc] Error: ${response.message}');
      }

      emit(state.copyWith(detallesResponse: response));
    }
  }

  Future<void> _onLoadMoreDetalles(
    LoadMoreDetalles event,
    Emitter<DetalleAbastecimientoState> emit,
  ) async {
    if (state.isLoadingMore || state.meta?.hasNext != true) {
      return;
    }

    if (kDebugMode) {
      print('📋 [DetalleAbastecimientoBloc] Cargando más detalles (página: ${state.currentPage + 1})');
    }

    emit(state.copyWith(isLoadingMore: true));

    final response = await useCases.getDetallesAbastecimiento.run(
      grifoId: state.currentGrifoId,
      page: state.currentPage + 1,
      pageSize: 10,
    );

    if (response is Success<Map<String, dynamic>>) {
      final data = response.data;
      final newDetalles = data['detalles'] as List<DetalleAbastecimiento>;
      final meta = data['meta'] as DetalleAbastecimientoMeta;

      final updatedDetalles = [...state.detalles, ...newDetalles];

      if (kDebugMode) {
        print('✅ [DetalleAbastecimientoBloc] ${newDetalles.length} detalles más cargados');
      }

      emit(state.copyWith(
        detalles: updatedDetalles,
        meta: meta,
        currentPage: state.currentPage + 1,
        isLoadingMore: false,
      ));
    } else {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onActualizarDetalle(
    ActualizarDetalleEvent event,
    Emitter<DetalleAbastecimientoState> emit,
  ) async {
    if (kDebugMode) {
      print('📝 [DetalleAbastecimientoBloc] Actualizando detalle: ${event.detalleId}');
    }

    emit(state.copyWith(actualizarResponse: Loading<DetalleAbastecimiento>()));

    final response = await useCases.actualizarDetalle.run(
      detalleId: event.detalleId,
      data: event.data,
    );

    if (response is Success<DetalleAbastecimiento>) {
      if (kDebugMode) {
        print('✅ [DetalleAbastecimientoBloc] Detalle actualizado exitosamente');
      }

      // Actualizar el detalle en la lista local
      final updatedDetalles = state.detalles.map((detalle) {
        if (detalle.id == event.detalleId) {
          return response.data;
        }
        return detalle;
      }).toList();

      emit(state.copyWith(
        actualizarResponse: response,
        detalles: updatedDetalles,
      ));
    } else if (response is Error<DetalleAbastecimiento>) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoBloc] Error al actualizar: ${response.message}');
      }

      emit(state.copyWith(actualizarResponse: response));
    }
  }

  Future<void> _onConcluirDetalle(
    ConcluirDetalleEvent event,
    Emitter<DetalleAbastecimientoState> emit,
  ) async {
    if (kDebugMode) {
      print('✅ [DetalleAbastecimientoBloc] Concluyendo detalle: ${event.detalleId}');
    }

    emit(state.copyWith(concluirResponse: Loading<DetalleAbastecimiento>()));

    final response = await useCases.concluirDetalle.run(
      detalleId: event.detalleId,
      concluidoPorId: event.concluidoPorId,
    );

    if (response is Success<DetalleAbastecimiento>) {
      if (kDebugMode) {
        print('✅ [DetalleAbastecimientoBloc] Detalle concluido exitosamente');
      }

      // Actualizar el detalle en la lista local
      final updatedDetalles = state.detalles.map((detalle) {
        if (detalle.id == event.detalleId) {
          return response.data;
        }
        return detalle;
      }).toList();

      emit(state.copyWith(
        concluirResponse: response,
        detalles: updatedDetalles,
      ));
    } else if (response is Error<DetalleAbastecimiento>) {
      if (kDebugMode) {
        print('❌ [DetalleAbastecimientoBloc] Error al concluir: ${response.message}');
      }

      emit(state.copyWith(concluirResponse: response));
    }
  }

  Future<void> _onResetDetallesState(
    ResetDetallesState event,
    Emitter<DetalleAbastecimientoState> emit,
  ) async {
    emit(const DetalleAbastecimientoState());
  }
}
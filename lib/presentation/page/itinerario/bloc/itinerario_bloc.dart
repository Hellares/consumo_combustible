// lib/presentation/page/itinerario/bloc/itinerario_bloc.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/use_cases/itinerario/itinerario_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_event.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItinerarioBloc extends Bloc<ItinerarioEvent, ItinerarioState> {
  final ItinerarioUseCases itinerarioUseCases;

  ItinerarioBloc(this.itinerarioUseCases) : super(const ItinerarioState()) {
    on<LoadItinerariosActivos>(_onLoadItinerariosActivos);
    on<ClearItinerarios>(_onClearItinerarios);
    on<LoadItinerarioById>(_onLoadItinerarioById);
    on<LoadItinerarioByCodigo>(_onLoadItinerarioByCodigo);
    on<ClearItinerarioDetalle>(_onClearItinerarioDetalle);
  }

  Future<void> _onLoadItinerariosActivos(
    LoadItinerariosActivos event,
    Emitter<ItinerarioState> emit,
  ) async {
    if (kDebugMode) {
      print('🗺️ [ItinerarioBloc] Cargando itinerarios activos...');
    }

    emit(state.copyWith(itinerariosResponse: Loading<List<Itinerario>>()));

    final response = await itinerarioUseCases.getItinerariosActivos.run();

    if (response is Success<List<Itinerario>>) {
      if (kDebugMode) {
        print('✅ [ItinerarioBloc] Itinerarios cargados: ${response.data.length}');
        for (var it in response.data) {
          print('   - ${it.nombre} (${it.codigo})');
        }
      }

      emit(state.copyWith(
        itinerariosResponse: response,
        itinerarios: response.data,
      ));
    } else if (response is Error<List<Itinerario>>) {
      if (kDebugMode) {
        print('❌ [ItinerarioBloc] Error: ${response.message}');
      }

      emit(state.copyWith(
        itinerariosResponse: response,
        itinerarios: [],
      ));
    }
  }

  Future<void> _onClearItinerarios(
    ClearItinerarios event,
    Emitter<ItinerarioState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [ItinerarioBloc] Limpiando itinerarios');
    }

    emit(const ItinerarioState());
  }

  // ========================================
  // 🔥 NUEVOS HANDLERS
  // ========================================

  /// Handler: Cargar itinerario por ID (con tramos completos)
  Future<void> _onLoadItinerarioById(
    LoadItinerarioById event,
    Emitter<ItinerarioState> emit,
  ) async {
    if (kDebugMode) {
      print('🗺️ [ItinerarioBloc] Cargando itinerario ID: ${event.itinerarioId}...');
    }

    emit(state.copyWith(
      itinerarioDetalleResponse: Loading<Itinerario>(),
    ));

    final response = await itinerarioUseCases.getItinerarioById.run(event.itinerarioId);

    if (response is Success<Itinerario>) {
      final itinerario = response.data;

      if (kDebugMode) {
        print('✅ [ItinerarioBloc] Itinerario cargado: ${itinerario.nombre}');
        print('   Código: ${itinerario.codigo}');
        print('   Tipo: ${itinerario.tipoItinerario}');
        print('   Distancia total: ${itinerario.distanciaTotal} km');
        print('   Tramos: ${itinerario.tramos?.length}');
        
        for (var tramo in itinerario.tramos ?? []) {
          print('   ${tramo.orden}. ${tramo.ciudadOrigen} → ${tramo.ciudadDestino}');
          print('      Distancia: ${tramo.ruta.distanciaKm} km');
          print('      Tiempo: ${tramo.ruta.tiempoEstimadoMinutos} min');
          if (tramo.requiereAbastecimiento) {
            print('      ⛽ Requiere abastecimiento');
          }
        }
      }

      emit(state.copyWith(
        itinerarioDetalleResponse: response,
        itinerarioDetalle: itinerario,
      ));
    } else if (response is Error<Itinerario>) {
      if (kDebugMode) {
        print('❌ [ItinerarioBloc] Error al cargar itinerario: ${response.message}');
      }

      emit(state.copyWith(
        itinerarioDetalleResponse: response,
        itinerarioDetalle: null,
      ));
    }
  }

  /// Handler: Cargar itinerario por código
  Future<void> _onLoadItinerarioByCodigo(
    LoadItinerarioByCodigo event,
    Emitter<ItinerarioState> emit,
  ) async {
    if (kDebugMode) {
      print('🗺️ [ItinerarioBloc] Cargando itinerario código: ${event.codigo}...');
    }

    emit(state.copyWith(
      itinerarioDetalleResponse: Loading<Itinerario>(),
    ));

    final response = await itinerarioUseCases.getItinerarioByCodigo.run(event.codigo);

    if (response is Success<Itinerario>) {
      final itinerario = response.data;

      if (kDebugMode) {
        print('✅ [ItinerarioBloc] Itinerario cargado: ${itinerario.nombre}');
        print('   Tramos: ${itinerario.tramos?.length}');
      }

      emit(state.copyWith(
        itinerarioDetalleResponse: response,
        itinerarioDetalle: itinerario,
      ));
    } else if (response is Error<Itinerario>) {
      if (kDebugMode) {
        print('❌ [ItinerarioBloc] Error: ${response.message}');
      }

      emit(state.copyWith(
        itinerarioDetalleResponse: response,
        itinerarioDetalle: null,
      ));
    }
  }

  /// Handler: Limpiar el itinerario detallado
  Future<void> _onClearItinerarioDetalle(
    ClearItinerarioDetalle event,
    Emitter<ItinerarioState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [ItinerarioBloc] Limpiando itinerario detalle');
    }

    emit(state.copyWith(clearItinerarioDetalle: true));
  }
}
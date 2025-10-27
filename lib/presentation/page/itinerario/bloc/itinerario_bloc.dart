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
}
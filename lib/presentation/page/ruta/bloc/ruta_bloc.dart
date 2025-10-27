// lib/presentation/page/ruta/bloc/ruta_bloc.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/use_cases/ruta/ruta_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_event.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RutaBloc extends Bloc<RutaEvent, RutaState> {
  final RutaUseCases rutaUseCases;

  RutaBloc(this.rutaUseCases) : super(const RutaState()) {
    on<LoadRutasActivas>(_onLoadRutasActivas);
    on<ClearRutas>(_onClearRutas);
  }

  Future<void> _onLoadRutasActivas(
    LoadRutasActivas event,
    Emitter<RutaState> emit,
  ) async {
    if (kDebugMode) {
      print('🛣️ [RutaBloc] Cargando rutas activas...');
    }

    emit(state.copyWith(rutasResponse: Loading<List<Ruta>>()));

    final response = await rutaUseCases.getRutasActivas.run();

    if (response is Success<List<Ruta>>) {
      if (kDebugMode) {
        print('✅ [RutaBloc] Rutas cargadas: ${response.data.length}');
        for (var ruta in response.data) {
          print('   - ${ruta.nombre} (${ruta.trayecto})');
        }
      }

      emit(state.copyWith(
        rutasResponse: response,
        rutas: response.data,
      ));
    } else if (response is Error<List<Ruta>>) {
      if (kDebugMode) {
        print('❌ [RutaBloc] Error: ${response.message}');
      }

      emit(state.copyWith(
        rutasResponse: response,
        rutas: [],
      ));
    }
  }

  Future<void> _onClearRutas(
    ClearRutas event,
    Emitter<RutaState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [RutaBloc] Limpiando rutas');
    }

    emit(const RutaState());
  }
}
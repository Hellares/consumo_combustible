import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_event.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationUseCases locationUseCases;

  LocationBloc(this.locationUseCases) : super(const LocationState()) {
    on<LoadZonas>(_onLoadZonas);
    on<SelectZona>(_onSelectZona);
    on<LoadSedesByZona>(_onLoadSedesByZona);
    on<SelectSede>(_onSelectSede);
    on<LoadGrifosBySede>(_onLoadGrifosBySede);
    on<SelectGrifo>(_onSelectGrifo);
    on<SaveLocation>(_onSaveLocation);
    on<LoadSavedLocation>(_onLoadSavedLocation);
    on<ClearLocation>(_onClearLocation);
  }

  Future<void> _onLoadZonas(LoadZonas event, Emitter emit) async {
    try {
      emit(state.copyWith(zonasResponse: Loading<dynamic>()));
      
      final response = await locationUseCases.getZonas.run();
      emit(state.copyWith(zonasResponse: response));
    } catch (e) {
      if (kDebugMode) print('❌ Error cargando zonas: $e');
      emit(state.copyWith(zonasResponse: Error(e.toString())));
    }
  }

  Future<void> _onSelectZona(SelectZona event, Emitter emit) async {
    emit(state.copyWith(selectedZona: event.zona));
    add(LoadSedesByZona(event.zona.id));
  }

  Future<void> _onLoadSedesByZona(LoadSedesByZona event, Emitter emit) async {
    try {
      emit(state.copyWith(sedesResponse: Loading<dynamic>()));
      
      final response = await locationUseCases.getSedesByZona.run(event.zonaId);
      emit(state.copyWith(sedesResponse: response));
    } catch (e) {
      if (kDebugMode) print('❌ Error cargando sedes: $e');
      emit(state.copyWith(sedesResponse: Error(e.toString())));
    }
  }

  Future<void> _onSelectSede(SelectSede event, Emitter emit) async {
    emit(state.copyWith(selectedSede: event.sede));
    add(LoadGrifosBySede(event.sede.id));
  }

  Future<void> _onLoadGrifosBySede(LoadGrifosBySede event, Emitter emit) async {
    try {
      emit(state.copyWith(grifosResponse: Loading<dynamic>()));
      
      final response = await locationUseCases.getGrifosBySede.run(event.sedeId);
      emit(state.copyWith(grifosResponse: response));
    } catch (e) {
      if (kDebugMode) print('❌ Error cargando grifos: $e');
      emit(state.copyWith(grifosResponse: Error(e.toString())));
    }
  }

  Future<void> _onSelectGrifo(SelectGrifo event, Emitter emit) async {
    emit(state.copyWith(selectedGrifo: event.grifo));
  }

  Future<void> _onSaveLocation(SaveLocation event, Emitter emit) async {
    try {
      if (state.selectedZona != null &&
          state.selectedSede != null &&
          state.selectedGrifo != null) {
        
        final location = SelectedLocation(
          zona: state.selectedZona!,
          sede: state.selectedSede!,
          grifo: state.selectedGrifo!,
          selectedAt: DateTime.now(),
        );

        await locationUseCases.saveSelectedLocation.run(location);
        
        emit(state.copyWith(
          saveResponse: Success('Ubicación guardada exitosamente'),
          savedLocation: location,
        ));
        
        if (kDebugMode) print('✅ Ubicación guardada: ${location.grifo.nombre}');
      } else {
        emit(state.copyWith(
          saveResponse: Error('Debe seleccionar zona, sede y grifo'),
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error guardando ubicación: $e');
      emit(state.copyWith(saveResponse: Error(e.toString())));
    }
  }

  Future<void> _onLoadSavedLocation(LoadSavedLocation event, Emitter emit) async {
    try {
      final location = await locationUseCases.getSelectedLocation.run();
      
      if (location != null) {
        emit(state.copyWith(
          savedLocation: location,
          selectedZona: location.zona,
          selectedSede: location.sede,
          selectedGrifo: location.grifo,
        ));
        
        if (kDebugMode) print('✅ Ubicación cargada: ${location.grifo.nombre}');
      } else {
        if (kDebugMode) print('ℹ️ No hay ubicación guardada');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error cargando ubicación guardada: $e');
    }
  }

  Future<void> _onClearLocation(ClearLocation event, Emitter emit) async {
    try {
      await locationUseCases.clearSelectedLocation.run();
      emit(const LocationState());
      
      if (kDebugMode) print('✅ Ubicación limpiada');
    } catch (e) {
      if (kDebugMode) print('❌ Error limpiando ubicación: $e');
      emit(state.copyWith(saveResponse: Error(e.toString())));
    }
  }
}
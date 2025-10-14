
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/sede_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/zona/zona_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_event.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SedeBloc extends Bloc<SedeEvent, SedeState> {
  final SedeUseCases _sedeUseCases;
  final ZonaUseCases _zonaUseCases;

  SedeBloc(this._sedeUseCases, this._zonaUseCases) : super(const SedeState()) {
    on<InitSedeFormEvent>(_onInitSedeForm);
    on<LoadSedesEvent>(_onLoadSedes);
    on<LoadZonasForDropdownEvent>(_onLoadZonasForDropdown);
    on<CreateSedeEvent>(_onCreateSede);
    on<SedeZonaSelectedEvent>(_onSedeZonaSelected);
    on<SedeNameChangedEvent>(_onSedeNameChanged);
    on<SedeCodigoChangedEvent>(_onSedeCodigoChanged);
    on<SedeDireccionChangedEvent>(_onSedeDireccionChanged);
    on<SedeTelefonoChangedEvent>(_onSedeTelefonoChanged);
    on<SedeActivoChangedEvent>(_onSedeActivoChanged);
    on<ResetSedeFormEvent>(_onResetSedeForm);
  }

  /// Inicializar formulario
  Future<void> _onInitSedeForm(
    InitSedeFormEvent event,
    Emitter<SedeState> emit,
  ) async {
    if (kDebugMode) print('🔷 [SedeBloc] Inicializando formulario');
    emit(state.resetForm());
    add(const LoadZonasForDropdownEvent());
    add(const LoadSedesEvent());
  }

  /// Cargar zonas para el dropdown
  Future<void> _onLoadZonasForDropdown(
    LoadZonasForDropdownEvent event,
    Emitter<SedeState> emit,
  ) async {
    try {
      // if (kDebugMode) print('🔷 [SedeBloc] Cargando zonas para dropdown...');
      
      emit(state.copyWith(isLoadingZonas: true));

      final result = await _zonaUseCases.getZonas.run();

      if (result is Success<List<Zona>>) {
        if (kDebugMode) {
          print('✅ [SedeBloc] ${result.data.length} zonas cargadas para dropdown');
        }
        emit(state.copyWith(
          isLoadingZonas: false,
          zonas: result.data,
          zonasResponse: result,
        ));
      } else if (result is Error<List<Zona>>) {
        if (kDebugMode) print('❌ [SedeBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoadingZonas: false,
          zonasResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [SedeBloc] Excepción: $e');
      emit(state.copyWith(
        isLoadingZonas: false,
        zonasResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Cargar sedes
  Future<void> _onLoadSedes(
    LoadSedesEvent event,
    Emitter<SedeState> emit,
  ) async {
    try {
      if (kDebugMode) print('🔷 [SedeBloc] Cargando sedes...');
      
      emit(state.copyWith(isLoadingSedes: true));

      final result = await _sedeUseCases.getSedes.run();

      if (result is Success<List<Sede>>) {
        if (kDebugMode) {
          print('✅ [SedeBloc] ${result.data.length} sedes cargadas');
        }
        emit(state.copyWith(
          isLoadingSedes: false,
          sedes: result.data,
          sedesResponse: result,
        ));
      } else if (result is Error<List<Sede>>) {
        if (kDebugMode) print('❌ [SedeBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoadingSedes: false,
          sedesResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [SedeBloc] Excepción: $e');
      emit(state.copyWith(
        isLoadingSedes: false,
        sedesResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Crear sede
  Future<void> _onCreateSede(
    CreateSedeEvent event,
    Emitter<SedeState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔷 [SedeBloc] Creando sede: ${event.request.nombre}');
      }

      emit(state.copyWith(isLoading: true, createSedeResponse: null));

      final result = await _sedeUseCases.createSede.run(event.request);

      if (result is Success<Sede>) {
        if (kDebugMode) {
          print('✅ [SedeBloc] Sede creada: ${result.data.nombre}');
        }
        
        // Emitir éxito
        emit(state.copyWith(
          isLoading: false,
          createSedeResponse: result,
        ));

        // Recargar sedes después de crear
        add(const LoadSedesEvent());
        
        // Resetear formulario
        await Future.delayed(const Duration(milliseconds: 500));
        add(const ResetSedeFormEvent());
        
      } else if (result is Error<Sede>) {
        if (kDebugMode) print('❌ [SedeBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoading: false,
          createSedeResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [SedeBloc] Excepción: $e');
      emit(state.copyWith(
        isLoading: false,
        createSedeResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Seleccionar zona
  void _onSedeZonaSelected(
    SedeZonaSelectedEvent event,
    Emitter<SedeState> emit,
  ) {
    final zonaError = event.zonaId > 0 ? null : 'Debe seleccionar una zona';
    
    emit(state.copyWith(
      selectedZonaId: event.zonaId,
      zonaError: zonaError,
      isFormValid: _isFormValid(
        zonaId: event.zonaId,
        nombre: state.nombre,
        codigo: state.codigo,
        zonaError: zonaError,
        nombreError: state.nombreError,
        codigoError: state.codigoError,
      ),
    ));
  }

  /// Cambiar nombre
  void _onSedeNameChanged(
    SedeNameChangedEvent event,
    Emitter<SedeState> emit,
  ) {
    final nombreError = _validateNombre(event.nombre);
    
    emit(state.copyWith(
      nombre: event.nombre,
      nombreError: nombreError,
      isFormValid: _isFormValid(
        zonaId: state.selectedZonaId,
        nombre: event.nombre,
        codigo: state.codigo,
        zonaError: state.zonaError,
        nombreError: nombreError,
        codigoError: state.codigoError,
      ),
    ));
  }

  /// Cambiar código
  void _onSedeCodigoChanged(
    SedeCodigoChangedEvent event,
    Emitter<SedeState> emit,
  ) {
    final codigoError = _validateCodigo(event.codigo);
    
    emit(state.copyWith(
      codigo: event.codigo,
      codigoError: codigoError,
      isFormValid: _isFormValid(
        zonaId: state.selectedZonaId,
        nombre: state.nombre,
        codigo: event.codigo,
        zonaError: state.zonaError,
        nombreError: state.nombreError,
        codigoError: codigoError,
      ),
    ));
  }

  /// Cambiar dirección
  void _onSedeDireccionChanged(
    SedeDireccionChangedEvent event,
    Emitter<SedeState> emit,
  ) {
    emit(state.copyWith(direccion: event.direccion));
  }

  /// Cambiar teléfono
  void _onSedeTelefonoChanged(
    SedeTelefonoChangedEvent event,
    Emitter<SedeState> emit,
  ) {
    emit(state.copyWith(telefono: event.telefono));
  }

  /// Cambiar activo
  void _onSedeActivoChanged(
    SedeActivoChangedEvent event,
    Emitter<SedeState> emit,
  ) {
    emit(state.copyWith(activo: event.activo));
  }

  /// Resetear formulario
  void _onResetSedeForm(
    ResetSedeFormEvent event,
    Emitter<SedeState> emit,
  ) {
    if (kDebugMode) print('🔷 [SedeBloc] Reseteando formulario');
    emit(state.resetForm().copyWith(
      createSedeResponse: null,
    ));
  }

  // ========== VALIDACIONES ==========

  String? _validateNombre(String nombre) {
    if (nombre.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    if (nombre.trim().length < 3) {
      return 'El nombre debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _validateCodigo(String codigo) {
    if (codigo.trim().isEmpty) {
      return 'El código es requerido';
    }
    if (codigo.trim().length < 2) {
      return 'El código debe tener al menos 2 caracteres';
    }
    return null;
  }

  bool _isFormValid({
    int? zonaId,
    required String nombre,
    required String codigo,
    String? zonaError,
    String? nombreError,
    String? codigoError,
  }) {
    return zonaId != null &&
        zonaId > 0 &&
        nombre.trim().isNotEmpty &&
        codigo.trim().isNotEmpty &&
        zonaError == null &&
        nombreError == null &&
        codigoError == null;
  }
}
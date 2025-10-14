
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/use_cases/zona/zona_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_event.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ZonaBloc extends Bloc<ZonaEvent, ZonaState> {
  final ZonaUseCases _zonaUseCases;

  ZonaBloc(this._zonaUseCases) : super(const ZonaState()) {
    on<InitZonaFormEvent>(_onInitZonaForm);
    on<LoadZonasEvent>(_onLoadZonas);
    on<CreateZonaEvent>(_onCreateZona);
    on<ZonaNameChangedEvent>(_onZonaNameChanged);
    on<ZonaCodigoChangedEvent>(_onZonaCodigoChanged);
    on<ZonaDescripcionChangedEvent>(_onZonaDescripcionChanged);
    on<ZonaActivoChangedEvent>(_onZonaActivoChanged);
    on<ResetZonaFormEvent>(_onResetZonaForm);
  }

  /// Inicializar formulario
  Future<void> _onInitZonaForm(
    InitZonaFormEvent event,
    Emitter<ZonaState> emit,
  ) async {
    if (kDebugMode) print('🔷 [ZonaBloc] Inicializando formulario');
    emit(state.resetForm());
    add(const LoadZonasEvent());
  }

  /// Cargar zonas
  Future<void> _onLoadZonas(
    LoadZonasEvent event,
    Emitter<ZonaState> emit,
  ) async {
    try {
      if (kDebugMode) print('🔷 [ZonaBloc] Cargando zonas...');
      
      emit(state.copyWith(isLoadingZonas: true));

      final result = await _zonaUseCases.getZonas.run();

      if (result is Success<List<Zona>>) {
        if (kDebugMode) {
          print('✅ [ZonaBloc] ${result.data.length} zonas cargadas');
        }
        emit(state.copyWith(
          isLoadingZonas: false,
          zonas: result.data,
          zonasResponse: result,
        ));
      } else if (result is Error<List<Zona>>) {
        if (kDebugMode) print('❌ [ZonaBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoadingZonas: false,
          zonasResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [ZonaBloc] Excepción: $e');
      emit(state.copyWith(
        isLoadingZonas: false,
        zonasResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Crear zona
  Future<void> _onCreateZona(
    CreateZonaEvent event,
    Emitter<ZonaState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔷 [ZonaBloc] Creando zona: ${event.request.nombre}');
      }

      emit(state.copyWith(isLoading: true, createZonaResponse: null));

      final result = await _zonaUseCases.createZona.run(event.request);

      if (result is Success<Zona>) {
        if (kDebugMode) {
          print('✅ [ZonaBloc] Zona creada: ${result.data.nombre}');
        }
        
        // Emitir éxito
        emit(state.copyWith(
          isLoading: false,
          createZonaResponse: result,
        ));

        // Recargar zonas después de crear
        add(const LoadZonasEvent());
        
        // Resetear formulario
        await Future.delayed(const Duration(milliseconds: 500));
        add(const ResetZonaFormEvent());
        
      } else if (result is Error<Zona>) {
        if (kDebugMode) print('❌ [ZonaBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoading: false,
          createZonaResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [ZonaBloc] Excepción: $e');
      emit(state.copyWith(
        isLoading: false,
        createZonaResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Cambiar nombre
  void _onZonaNameChanged(
    ZonaNameChangedEvent event,
    Emitter<ZonaState> emit,
  ) {
    final nombreError = _validateNombre(event.nombre);
    
    emit(state.copyWith(
      nombre: event.nombre,
      nombreError: nombreError,
      isFormValid: _isFormValid(
        nombre: event.nombre,
        codigo: state.codigo,
        nombreError: nombreError,
        codigoError: state.codigoError,
      ),
    ));
  }

  /// Cambiar código
  void _onZonaCodigoChanged(
    ZonaCodigoChangedEvent event,
    Emitter<ZonaState> emit,
  ) {
    final codigoError = _validateCodigo(event.codigo);
    
    emit(state.copyWith(
      codigo: event.codigo,
      codigoError: codigoError,
      isFormValid: _isFormValid(
        nombre: state.nombre,
        codigo: event.codigo,
        nombreError: state.nombreError,
        codigoError: codigoError,
      ),
    ));
  }

  /// Cambiar descripción
  void _onZonaDescripcionChanged(
    ZonaDescripcionChangedEvent event,
    Emitter<ZonaState> emit,
  ) {
    emit(state.copyWith(descripcion: event.descripcion));
  }

  /// Cambiar activo
  void _onZonaActivoChanged(
    ZonaActivoChangedEvent event,
    Emitter<ZonaState> emit,
  ) {
    emit(state.copyWith(activo: event.activo));
  }

  /// Resetear formulario
  void _onResetZonaForm(
    ResetZonaFormEvent event,
    Emitter<ZonaState> emit,
  ) {
    if (kDebugMode) print('🔷 [ZonaBloc] Reseteando formulario');
    emit(state.resetForm().copyWith(
      zonas: state.zonas, // Mantener las zonas cargadas
      createZonaResponse: null,
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
    required String nombre,
    required String codigo,
    String? nombreError,
    String? codigoError,
  }) {
    return nombre.trim().isNotEmpty &&
        codigo.trim().isNotEmpty &&
        nombreError == null &&
        codigoError == null;
  }
}
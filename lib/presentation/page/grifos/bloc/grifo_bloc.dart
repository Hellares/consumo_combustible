import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/grifo_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/sede_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_event.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GrifoBloc extends Bloc<GrifoEvent, GrifoState> {
  final GrifoUseCases _grifoUseCases;
  final SedeUseCases _sedeUseCases;

  GrifoBloc(this._grifoUseCases, this._sedeUseCases) : super(const GrifoState()) {
    on<InitGrifoFormEvent>(_onInitGrifoForm);
    on<LoadGrifosEvent>(_onLoadGrifos);
    on<LoadSedesForDropdownEvent>(_onLoadSedesForDropdown);
    on<CreateGrifoEvent>(_onCreateGrifo);
    on<GrifoSedeSelectedEvent>(_onGrifoSedeSelected);
    on<GrifoNameChangedEvent>(_onGrifoNameChanged);
    on<GrifoCodigoChangedEvent>(_onGrifoCodigoChanged);
    on<GrifoDireccionChangedEvent>(_onGrifoDireccionChanged);
    on<GrifoTelefonoChangedEvent>(_onGrifoTelefonoChanged);
    on<GrifoHorarioAperturaChangedEvent>(_onGrifoHorarioAperturaChanged);
    on<GrifoHorarioCierreChangedEvent>(_onGrifoHorarioCierreChanged);
    on<GrifoActivoChangedEvent>(_onGrifoActivoChanged);
    on<ResetGrifoFormEvent>(_onResetGrifoForm);
    on<LoadGrifoByIdEvent>(_onLoadGrifoById);  
    on<UpdateGrifoEvent>(_onUpdateGrifo);      
    on<InitEditGrifoFormEvent>(_onInitEditGrifoForm);
  }

  /// Inicializar formulario
  Future<void> _onInitGrifoForm(
    InitGrifoFormEvent event,
    Emitter<GrifoState> emit,
  ) async {
    if (kDebugMode) print('🔷 [GrifoBloc] Inicializando formulario');
    emit(state.resetForm());
    add(const LoadSedesForDropdownEvent());
    add(const LoadGrifosEvent());
  }

  /// Cargar sedes para el dropdown
  Future<void> _onLoadSedesForDropdown(
    LoadSedesForDropdownEvent event,
    Emitter<GrifoState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingSedes: true));

      final result = await _sedeUseCases.getSedes.run();

      if (result is Success<List<Sede>>) {
        if (kDebugMode) {
          print('✅ [GrifoBloc] ${result.data.length} sedes para dropdown');
        }
        emit(state.copyWith(
          isLoadingSedes: false,
          sedes: result.data,
          sedesResponse: result,
        ));
      } else if (result is Error<List<Sede>>) {
        if (kDebugMode) print('❌ [GrifoBloc] Error sedes: ${result.message}');
        emit(state.copyWith(
          isLoadingSedes: false,
          sedesResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [GrifoBloc] Excepción sedes: $e');
      emit(state.copyWith(
        isLoadingSedes: false,
        sedesResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Cargar grifos
  Future<void> _onLoadGrifos(
    LoadGrifosEvent event,
    Emitter<GrifoState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoadingGrifos: true));

      final result = await _grifoUseCases.getGrifos.run();

      if (result is Success<List<Grifo>>) {
        if (kDebugMode) {
          print('✅ [GrifoBloc] ${result.data.length} grifos cargados');
        }
        emit(state.copyWith(
          isLoadingGrifos: false,
          grifos: result.data,
          grifosResponse: result,
        ));
      } else if (result is Error<List<Grifo>>) {
        if (kDebugMode) print('❌ [GrifoBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoadingGrifos: false,
          grifosResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [GrifoBloc] Excepción: $e');
      emit(state.copyWith(
        isLoadingGrifos: false,
        grifosResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Crear grifo
  Future<void> _onCreateGrifo(
    CreateGrifoEvent event,
    Emitter<GrifoState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔷 [GrifoBloc] Creando grifo: ${event.request.nombre}');
      }

      emit(state.copyWith(isLoading: true, createGrifoResponse: null));

      final result = await _grifoUseCases.createGrifo.run(event.request);

      if (result is Success<Grifo>) {
        if (kDebugMode) {
          print('✅ [GrifoBloc] Grifo creado: ${result.data.nombre}');
        }
        
        emit(state.copyWith(
          isLoading: false,
          createGrifoResponse: result,
        ));

        add(const LoadGrifosEvent());
        
        await Future.delayed(const Duration(milliseconds: 500));
        add(const ResetGrifoFormEvent());
        
      } else if (result is Error<Grifo>) {
        if (kDebugMode) print('❌ [GrifoBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoading: false,
          createGrifoResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [GrifoBloc] Excepción: $e');
      emit(state.copyWith(
        isLoading: false,
        createGrifoResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Seleccionar sede
  void _onGrifoSedeSelected(
    GrifoSedeSelectedEvent event,
    Emitter<GrifoState> emit,
  ) {
    final sedeError = event.sedeId > 0 ? null : 'Debe seleccionar una sede';
    
    emit(state.copyWith(
      selectedSedeId: event.sedeId,
      sedeError: sedeError,
      isFormValid: _isFormValid(
        sedeId: event.sedeId,
        nombre: state.nombre,
        codigo: state.codigo,
        sedeError: sedeError,
        nombreError: state.nombreError,
        codigoError: state.codigoError,
      ),
    ));
  }

  /// Cambiar nombre
  void _onGrifoNameChanged(
    GrifoNameChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    final nombreError = _validateNombre(event.nombre);
    
    emit(state.copyWith(
      nombre: event.nombre,
      nombreError: nombreError,
      isFormValid: _isFormValid(
        sedeId: state.selectedSedeId,
        nombre: event.nombre,
        codigo: state.codigo,
        sedeError: state.sedeError,
        nombreError: nombreError,
        codigoError: state.codigoError,
      ),
    ));
  }

  /// Cambiar código
  void _onGrifoCodigoChanged(
    GrifoCodigoChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    final codigoError = _validateCodigo(event.codigo);
    
    emit(state.copyWith(
      codigo: event.codigo,
      codigoError: codigoError,
      isFormValid: _isFormValid(
        sedeId: state.selectedSedeId,
        nombre: state.nombre,
        codigo: event.codigo,
        sedeError: state.sedeError,
        nombreError: state.nombreError,
        codigoError: codigoError,
      ),
    ));
  }

  /// Cambiar dirección
  void _onGrifoDireccionChanged(
    GrifoDireccionChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    emit(state.copyWith(direccion: event.direccion));
  }

  /// Cambiar teléfono
  void _onGrifoTelefonoChanged(
    GrifoTelefonoChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    emit(state.copyWith(telefono: event.telefono));
  }

  /// Cambiar horario apertura
  void _onGrifoHorarioAperturaChanged(
    GrifoHorarioAperturaChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    emit(state.copyWith(horarioApertura: event.horarioApertura));
  }

  /// Cambiar horario cierre
  void _onGrifoHorarioCierreChanged(
    GrifoHorarioCierreChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    emit(state.copyWith(horarioCierre: event.horarioCierre));
  }

  /// Cambiar activo
  void _onGrifoActivoChanged(
    GrifoActivoChangedEvent event,
    Emitter<GrifoState> emit,
  ) {
    emit(state.copyWith(activo: event.activo));
  }

  /// Resetear formulario
  void _onResetGrifoForm(
    ResetGrifoFormEvent event,
    Emitter<GrifoState> emit,
  ) {
    if (kDebugMode) print('🔷 [GrifoBloc] Reseteando formulario');
    emit(state.resetForm().copyWith(
      createGrifoResponse: null,
    ));
  }

  /// Inicializar formulario de edición
  Future<void> _onInitEditGrifoForm(
    InitEditGrifoFormEvent event,
    Emitter<GrifoState> emit,
  ) async {
    if (kDebugMode) print('🔷 [GrifoBloc] Inicializando formulario de edición');

    // Resetear el formulario antes de cargar datos nuevos
    emit(state.resetForm().copyWith(
      isEditMode: true,
      editingGrifoId: event.grifoId,
    ));

    // Solo cargar el grifo, no necesitamos cargar sedes ya que el grifo incluye la sede
    add(LoadGrifoByIdEvent(event.grifoId));
  }

  /// Cargar grifo por ID
  Future<void> _onLoadGrifoById(
    LoadGrifoByIdEvent event,
    Emitter<GrifoState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔷 [GrifoBloc] Cargando grifo ID: ${event.grifoId}');
      }

      emit(state.copyWith(isLoadingGrifoById: true));

      final result = await _grifoUseCases.getGrifoById.run(event.grifoId);

      if (result is Success<Grifo>) {
        final grifo = result.data;
        
        if (kDebugMode) {
          print('✅ [GrifoBloc] Grifo cargado: ${grifo.nombre}');
        }

        // Validar campos antes de emitir
        final nombreError = _validateNombre(grifo.nombre);
        final codigoError = _validateCodigo(grifo.codigo ?? '');
        
        emit(state.copyWith(
          isLoadingGrifoById: false,
          grifoByIdResponse: result,
          selectedSedeId: grifo.sedeId,
          nombre: grifo.nombre,
          codigo: grifo.codigo ?? '',
          direccion: grifo.direccion ?? '',
          telefono: grifo.telefono ?? '',
          horarioApertura: grifo.horarioApertura ?? '',
          horarioCierre: grifo.horarioCierre ?? '',
          activo: grifo.activo ?? true,
          nombreError: nombreError,
          codigoError: codigoError,
          isFormValid: _isFormValid(
            sedeId: grifo.sedeId,
            nombre: grifo.nombre,
            codigo: grifo.codigo ?? '',
            sedeError: null,
            nombreError: nombreError,
            codigoError: codigoError,
          ),
        ));
      } else if (result is Error<Grifo>) {
        if (kDebugMode) print('❌ [GrifoBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoadingGrifoById: false,
          grifoByIdResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [GrifoBloc] Excepción: $e');
      emit(state.copyWith(
        isLoadingGrifoById: false,
        grifoByIdResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Actualizar grifo
  Future<void> _onUpdateGrifo(
    UpdateGrifoEvent event,
    Emitter<GrifoState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔷 [GrifoBloc] Actualizando grifo ID: ${event.grifoId}');
      }

      emit(state.copyWith(isLoading: true, updateGrifoResponse: null));

      final result = await _grifoUseCases.updateGrifo.run(
        event.grifoId,
        event.request,
      );

      if (result is Success<Grifo>) {
        if (kDebugMode) {
          print('✅ [GrifoBloc] Grifo actualizado: ${result.data.nombre}');
        }
        
        emit(state.copyWith(
          isLoading: false,
          updateGrifoResponse: result,
        ));

        add(const LoadGrifosEvent());
        
        await Future.delayed(const Duration(milliseconds: 500));
        add(const ResetGrifoFormEvent());
        
      } else if (result is Error<Grifo>) {
        if (kDebugMode) print('❌ [GrifoBloc] Error: ${result.message}');
        emit(state.copyWith(
          isLoading: false,
          updateGrifoResponse: result,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('❌ [GrifoBloc] Excepción: $e');
      emit(state.copyWith(
        isLoading: false,
        updateGrifoResponse: Error('Error inesperado: $e'),
      ));
    }
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
    int? sedeId,
    required String nombre,
    required String codigo,
    String? sedeError,
    String? nombreError,
    String? codigoError,
  }) {
    return sedeId != null &&
        sedeId > 0 &&
        nombre.trim().isNotEmpty &&
        codigo.trim().isNotEmpty &&
        sedeError == null &&
        nombreError == null &&
        codigoError == null;
  }
}
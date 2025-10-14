// lib/presentation/bloc/unidad/unidad_bloc.dart

import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_event.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnidadBloc extends Bloc<UnidadEvent, UnidadState> {
  final UnidadUseCases _unidadUseCases;

  UnidadBloc(this._unidadUseCases) : super(UnidadState.initial()) {
    on<LoadAllUnidades>(_onLoadAllUnidades);
    on<LoadUnidadesByZona>(_onLoadUnidadesByZona);
    on<LoadUnidadById>(_onLoadUnidadById);
    on<CreateUnidad>(_onCreateUnidad);
    on<ResetCreateUnidadState>(_onResetCreateUnidadState);
    on<ClearUnidadesCache>(_onClearUnidadesCache);
    on<LoadNextPage>(_onLoadNextPage);
  }

  /// Cargar todas las unidades con paginación
  Future<void> _onLoadAllUnidades(
    LoadAllUnidades event,
    Emitter<UnidadState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚗 [UnidadBloc] Cargando unidades - Página: ${event.page}');
      }

      // Si es refresh, mostrar loading completo
      if (event.refresh || event.page == 1) {
        emit(state.copyWith(
          status: UnidadStatus.loading,
          unidades: [], // Limpiar lista si es refresh
        ));
      } else {
        // Si es paginación, mostrar loadingMore
        emit(state.copyWith(status: UnidadStatus.loadingMore));
      }

      final result = await _unidadUseCases.getAllUnidades.run(
        page: event.page,
        pageSize: event.pageSize,
      );

      if (result is Success<UnidadesResponse>) {
        final response = result.data;
        
        if (kDebugMode) {
          print('✅ [UnidadBloc] ${response.data.length} unidades cargadas');
          print('📊 Total: ${response.meta.total}');
          print('📄 Página: ${response.meta.page}/${response.meta.totalPages}');
        }

        // Si es la primera página o refresh, reemplazar lista
        // Si es paginación, agregar a la lista existente
        final newUnidades = event.refresh || event.page == 1
            ? response.data
            : [...state.unidades, ...response.data];

        emit(state.copyWith(
          status: UnidadStatus.success,
          unidades: newUnidades,
          currentPage: response.meta.page,
          totalPages: response.meta.totalPages,
          total: response.meta.total,
          hasMore: response.meta.hasNext,
          errorMessage: null,
        ));
      } else if (result is Error<UnidadesResponse>) {
        if (kDebugMode) {
          print('❌ [UnidadBloc] Error: ${result.message}');
        }

        emit(state.copyWith(
          status: UnidadStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UnidadBloc] Excepción: $e');
      }

      emit(state.copyWith(
        status: UnidadStatus.error,
        errorMessage: 'Error inesperado: $e',
      ));
    }
  }

  /// Cargar unidades por zona
  Future<void> _onLoadUnidadesByZona(
    LoadUnidadesByZona event,
    Emitter<UnidadState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚗 [UnidadBloc] Cargando unidades de zona: ${event.zonaId}');
      }

      emit(state.copyWith(status: UnidadStatus.loading));

      final result = await _unidadUseCases.getUnidadesByZona.run(event.zonaId);

      if (result is Success<List<Unidad>>) {
        if (kDebugMode) {
          print('✅ [UnidadBloc] ${result.data.length} unidades cargadas');
        }

        emit(state.copyWith(
          status: UnidadStatus.success,
          unidades: result.data,
          errorMessage: null,
        ));
      } else if (result is Error<List<Unidad>>) {
        if (kDebugMode) {
          print('❌ [UnidadBloc] Error: ${result.message}');
        }

        emit(state.copyWith(
          status: UnidadStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UnidadBloc] Excepción: $e');
      }

      emit(state.copyWith(
        status: UnidadStatus.error,
        errorMessage: 'Error inesperado: $e',
      ));
    }
  }

  /// Cargar unidad por ID
  Future<void> _onLoadUnidadById(
    LoadUnidadById event,
    Emitter<UnidadState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚗 [UnidadBloc] Cargando unidad ID: ${event.unidadId}');
      }

      emit(state.copyWith(status: UnidadStatus.loading));

      final result = await _unidadUseCases.getUnidadById.run(event.unidadId);

      if (result is Success<Unidad>) {
        if (kDebugMode) {
          print('✅ [UnidadBloc] Unidad cargada: ${result.data.placa}');
        }

        emit(state.copyWith(
          status: UnidadStatus.success,
          selectedUnidad: result.data,
          errorMessage: null,
        ));
      } else if (result is Error<Unidad>) {
        if (kDebugMode) {
          print('❌ [UnidadBloc] Error: ${result.message}');
        }

        emit(state.copyWith(
          status: UnidadStatus.error,
          errorMessage: result.message,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UnidadBloc] Excepción: $e');
      }

      emit(state.copyWith(
        status: UnidadStatus.error,
        errorMessage: 'Error inesperado: $e',
      ));
    }
  }

  /// Crear nueva unidad
  Future<void> _onCreateUnidad(
    CreateUnidad event,
    Emitter<UnidadState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🚗 [UnidadBloc] Creando unidad: ${event.request.placa}');
      }

      emit(state.copyWith(
        status: UnidadStatus.creating,
        createErrorMessage: null,
      ));

      final result = await _unidadUseCases.createUnidad.run(event.request);

      if (result is Success<Unidad>) {
        if (kDebugMode) {
          print('✅ [UnidadBloc] Unidad creada: ${result.data.placa} (ID: ${result.data.id})');
        }

        emit(state.copyWith(
          status: UnidadStatus.created,
          createdUnidad: result.data,
          createErrorMessage: null,
        ));
      } else if (result is Error<Unidad>) {
        if (kDebugMode) {
          print('❌ [UnidadBloc] Error al crear: ${result.message}');
        }

        emit(state.copyWith(
          status: UnidadStatus.createError,
          createErrorMessage: result.message,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UnidadBloc] Excepción al crear: $e');
      }

      emit(state.copyWith(
        status: UnidadStatus.createError,
        createErrorMessage: 'Error inesperado: $e',
      ));
    }
  }

  /// Reset del estado de creación
  void _onResetCreateUnidadState(
    ResetCreateUnidadState event,
    Emitter<UnidadState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [UnidadBloc] Reseteando estado de creación');
    }

    emit(state.copyWith(
      status: UnidadStatus.success,
      createdUnidad: null,
      createErrorMessage: null,
    ));
  }

  /// Limpiar caché de unidades
  Future<void> _onClearUnidadesCache(
    ClearUnidadesCache event,
    Emitter<UnidadState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🗑️ [UnidadBloc] Limpiando caché${event.zonaId != null ? ' de zona ${event.zonaId}' : ''}');
      }

      await _unidadUseCases.clearUnidadesCache.run(zonaId: event.zonaId);

      if (kDebugMode) {
        print('✅ [UnidadBloc] Caché limpiado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [UnidadBloc] Error al limpiar caché: $e');
      }
    }
  }

  /// Cargar siguiente página (paginación infinita)
  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<UnidadState> emit,
  ) async {
    // Solo cargar si hay más páginas disponibles
    if (!state.hasMore) {
      if (kDebugMode) {
        print('⚠️ [UnidadBloc] No hay más páginas para cargar');
      }
      return;
    }

    // Evitar cargas duplicadas
    if (state.status == UnidadStatus.loadingMore) {
      if (kDebugMode) {
        print('⚠️ [UnidadBloc] Ya se está cargando la siguiente página');
      }
      return;
    }

    if (kDebugMode) {
      print('📄 [UnidadBloc] Cargando página ${state.currentPage + 1}');
    }

    add(LoadAllUnidades(
      page: state.currentPage + 1,
      refresh: false,
    ));
  }
}
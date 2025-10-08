// lib/presentation/page/licencias/bloc/licencia_bloc.dart

import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/licencia_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_event.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LicenciaBloc extends Bloc<LicenciaEvent, LicenciaState> {
  final LicenciaUseCases useCases;

  LicenciaBloc(this.useCases) : super(const LicenciaState()) {
    on<LoadLicencias>(_onLoadLicencias);
    on<LoadMoreLicencias>(_onLoadMoreLicencias);
    on<LoadLicenciaById>(_onLoadLicenciaById);
    on<LoadLicenciasByUsuario>(_onLoadLicenciasByUsuario);
    on<LoadLicenciasVencidas>(_onLoadLicenciasVencidas);
    on<LoadLicenciasProximasVencer>(_onLoadLicenciasProximasVencer);
    on<RefreshLicencias>(_onRefreshLicencias);
    on<FilterLicencias>(_onFilterLicencias);
    on<ResetLicenciaState>(_onResetState);
  }

  /// Cargar licencias con paginación
  Future<void> _onLoadLicencias(
    LoadLicencias event,
    Emitter<LicenciaState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (kDebugMode) {
        print('📋 [LicenciaBloc] Cargando licencias (page: ${event.page})...');
      }

      final response = await useCases.getLicencias.run(
        page: event.page,
        pageSize: event.pageSize,
      );

      if (response is Success<LicenciasResponse>) {
        final data = response.data;

        if (kDebugMode) {
          print('✅ ${data.data.length} licencias cargadas');
        }

        emit(state.copyWith(
          response: response,
          licencias: data.data,
          currentPage: data.meta.page,
          totalPages: data.meta.totalPages,
          totalLicencias: data.meta.total,
          hasMore: data.meta.hasNext,
          isLoading: false,
        ));
      } else if (response is Error<LicenciasResponse>) {
        if (kDebugMode) {
          print('❌ Error: ${response.message}');
        }

        emit(state.copyWith(
          response: response,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadLicencias: $e');
      }

      emit(state.copyWith(
        response: Error('Error inesperado: $e'),
        isLoading: false,
      ));
    }
  }

  /// Cargar más licencias (siguiente página)
  Future<void> _onLoadMoreLicencias(
    LoadMoreLicencias event,
    Emitter<LicenciaState> emit,
  ) async {
    if (!state.hasMore || state.isLoadingMore) return;

    try {
      emit(state.copyWith(isLoadingMore: true));

      final nextPage = state.currentPage + 1;

      if (kDebugMode) {
        print('📋 [LicenciaBloc] Cargando página $nextPage...');
      }

      final response = await useCases.getLicencias.run(page: nextPage);

      if (response is Success<LicenciasResponse>) {
        final data = response.data;
        final updatedLicencias = [...state.licencias, ...data.data];

        if (kDebugMode) {
          print('✅ ${data.data.length} licencias más cargadas (total: ${updatedLicencias.length})');
        }

        emit(state.copyWith(
          licencias: updatedLicencias,
          currentPage: data.meta.page,
          totalPages: data.meta.totalPages,
          hasMore: data.meta.hasNext,
          isLoadingMore: false,
        ));
      } else if (response is Error<LicenciasResponse>) {
        if (kDebugMode) {
          print('❌ Error cargando más: ${response.message}');
        }

        emit(state.copyWith(isLoadingMore: false));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadMoreLicencias: $e');
      }

      emit(state.copyWith(isLoadingMore: false));
    }
  }

  /// Cargar licencia por ID
  Future<void> _onLoadLicenciaById(
    LoadLicenciaById event,
    Emitter<LicenciaState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (kDebugMode) {
        print('🔍 [LicenciaBloc] Cargando licencia ${event.licenciaId}...');
      }

      final response = await useCases.getLicenciaById.run(licenciaId: event.licenciaId);

      if (response is Success<LicenciaConducir>) {
        if (kDebugMode) {
          print('✅ Licencia ${response.data.numeroLicencia} cargada');
        }

        emit(state.copyWith(
          selectedLicencia: response.data,
          isLoading: false,
        ));
      } else if (response is Error<LicenciaConducir>) {
        if (kDebugMode) {
          print('❌ Error: ${response.message}');
        }

        emit(state.copyWith(
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadLicenciaById: $e');
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Cargar licencias por usuario
  Future<void> _onLoadLicenciasByUsuario(
    LoadLicenciasByUsuario event,
    Emitter<LicenciaState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      if (kDebugMode) {
        print('👤 [LicenciaBloc] Cargando licencias del usuario ${event.usuarioId}...');
      }

      final response = await useCases.getLicenciasByUsuario.run(event.usuarioId);

      if (response is Success<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('✅ ${response.data.length} licencias encontradas');
        }

        emit(state.copyWith(
          licencias: response.data,
          totalLicencias: response.data.length,
          isLoading: false,
        ));
      } else if (response is Error<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('❌ Error: ${response.message}');
        }

        emit(state.copyWith(
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadLicenciasByUsuario: $e');
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Cargar licencias vencidas
  Future<void> _onLoadLicenciasVencidas(
    LoadLicenciasVencidas event,
    Emitter<LicenciaState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, estadoFiltro: 'VENCIDAS'));

      if (kDebugMode) {
        print('⚠️ [LicenciaBloc] Cargando licencias vencidas...');
      }

      final response = await useCases.getLicenciasVencidas.run();

      if (response is Success<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('✅ ${response.data.length} licencias vencidas encontradas');
        }

        emit(state.copyWith(
          licencias: response.data,
          totalLicencias: response.data.length,
          isLoading: false,
        ));
      } else if (response is Error<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('❌ Error: ${response.message}');
        }

        emit(state.copyWith(
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadLicenciasVencidas: $e');
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Cargar licencias próximas a vencer
  Future<void> _onLoadLicenciasProximasVencer(
    LoadLicenciasProximasVencer event,
    Emitter<LicenciaState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, estadoFiltro: 'PROXIMAS'));

      if (kDebugMode) {
        print('🔔 [LicenciaBloc] Cargando licencias próximas a vencer...');
      }

      final response = await useCases.getLicenciasProximasVencer.run();

      if (response is Success<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('✅ ${response.data.length} licencias próximas a vencer encontradas');
        }

        emit(state.copyWith(
          licencias: response.data,
          totalLicencias: response.data.length,
          isLoading: false,
        ));
      } else if (response is Error<List<LicenciaConducir>>) {
        if (kDebugMode) {
          print('❌ Error: ${response.message}');
        }

        emit(state.copyWith(
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception en _onLoadLicenciasProximasVencer: $e');
      }

      emit(state.copyWith(
        isLoading: false,
      ));
    }
  }

  /// Refrescar lista
  Future<void> _onRefreshLicencias(
    RefreshLicencias event,
    Emitter<LicenciaState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true));

    // Recargar desde página 1
    add(const LoadLicencias(page: 1));

    emit(state.copyWith(isRefreshing: false));
  }

  /// Filtrar licencias localmente
  void _onFilterLicencias(
    FilterLicencias event,
    Emitter<LicenciaState> emit,
  ) {
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(state.clearFilter());
      return;
    }

    final filtered = state.licencias.where((licencia) {
      return licencia.numeroLicencia.toLowerCase().contains(query) ||
          licencia.usuario.nombres.toLowerCase().contains(query) ||
          licencia.usuario.apellidos.toLowerCase().contains(query) ||
          licencia.usuario.dni.contains(query) ||
          licencia.categoria.toLowerCase().contains(query);
    }).toList();

    if (kDebugMode) {
      print('🔍 Filtrado: ${filtered.length} de ${state.licencias.length}');
    }

    emit(state.copyWith(
      licenciasFiltradas: filtered,
      searchQuery: query,
    ));
  }

  /// Resetear estado
  void _onResetState(
    ResetLicenciaState event,
    Emitter<LicenciaState> emit,
  ) {
    emit(const LicenciaState());
  }
}
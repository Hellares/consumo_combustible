import 'package:consumo_combustible/domain/models/ultimo_ticket_unidad.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketUseCases ticketUseCases;
  final UnidadUseCases unidadUseCases;

  TicketBloc(
    this.ticketUseCases,
    this.unidadUseCases,
  ) : super(const TicketState()) {
    on<CreateTicket>(_onCreateTicket);
    on<ResetTicketState>(_onResetTicketState);
    on<LoadUnidadesByZona>(_onLoadUnidadesByZona);
    on<ResetUnidades>(_onResetUnidades);
    on<LoadUltimoTicketByUnidad>(_onLoadUltimoTicketByUnidad);
    on<ClearUltimoTicket>(_onClearUltimoTicket);
  }

  /// Maneja la creación de un ticket de abastecimiento
  Future<void> _onCreateTicket(
    CreateTicket event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('🎫 [TicketBloc] Iniciando creación de ticket...');
    }

    emit(state.copyWith(createResponse: Loading<Map<String, dynamic>>()));

    final response = await ticketUseCases.createTicket.run(event.request);

    if (kDebugMode) {
      if (response is Success) {
        print('✅ [TicketBloc] Ticket creado exitosamente');
      } else if (response is Error) {
        print('❌ [TicketBloc] Error al crear ticket: ${response.toString()}');
      }
    }

    emit(state.copyWith(createResponse: response));
  }

  /// Resetea el estado completo del BLoC
  Future<void> _onResetTicketState(
    ResetTicketState event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [TicketBloc] Reseteando estado completo');
    }

    emit(const TicketState());
  }

  /// ✅ NUEVO: Carga las unidades de una zona específica
  Future<void> _onLoadUnidadesByZona(
    LoadUnidadesByZona event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('🚗 [TicketBloc] Cargando unidades de la zona: ${event.zonaId}');
    }

    emit(state.copyWith(unidadesResponse: Loading<List<Unidad>>()));

    final response = await unidadUseCases.getUnidadesByZona.run(event.zonaId);

    if (response is Success<List<Unidad>>) {
      if (kDebugMode) {
        print('✅ [TicketBloc] Unidades cargadas: ${response.data.length}');
        for (var unidad in response.data) {
          print('   - ${unidad.placa} (${unidad.marca} ${unidad.modelo})');
        }
      }

      emit(state.copyWith(
        unidadesResponse: response,
        unidades: response.data,
      ));
    } else if (response is Error) {
      if (kDebugMode) {
        print('❌ [TicketBloc] Error al cargar unidades: ${response.toString()}');
      }

      emit(state.copyWith(
        unidadesResponse: response,
        unidades: [], // Limpiar unidades en caso de error
      ));
    }
  }

  /// ✅ NUEVO: Resetea solo las unidades
  Future<void> _onResetUnidades(
    ResetUnidades event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [TicketBloc] Reseteando unidades');
    }

    emit(state.copyWith(
      unidadesResponse: null,
      unidades: [],
    ));
  }

  Future<void> _onLoadUltimoTicketByUnidad(
    LoadUltimoTicketByUnidad event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('📋 [TicketBloc] Cargando último ticket de la unidad: ${event.unidadId}');
    }

    emit(state.copyWith(ultimoTicketResponse: Loading()));

    final response = await ticketUseCases.getUltimoTicketByUnidad.run(event.unidadId);

    if (response is Success<UltimoTicketUnidad>) {
      if (kDebugMode) {
        print('✅ [TicketBloc] Último ticket cargado exitosamente');
        print('   Kilometraje sugerido: ${response.data.sugerencias.kilometrajeAnteriorSugerido}');
        print('   Precinto sugerido: ${response.data.sugerencias.precintoAnteriorSugerido}');
      }

      emit(state.copyWith(
        ultimoTicketResponse: response,
        ultimoTicket: response.data,
      ));
    } else if (response is Error<UltimoTicketUnidad>) {
      if (kDebugMode) {
        print('ℹ️ [TicketBloc] ${response.message}');
      }

      // No es un error crítico si la unidad no tiene tickets previos
      emit(state.copyWith(
        ultimoTicketResponse: response,
        ultimoTicket: null,
      ));
    }
  }

  Future<void> _onClearUltimoTicket(
    ClearUltimoTicket event,
    Emitter<TicketState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [TicketBloc] Limpiando último ticket');
    }

    emit(state.copyWith(clearUltimoTicket: true));
  }
}
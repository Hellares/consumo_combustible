import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/ticket_aprobacion_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketAprobacionBloc extends Bloc<TicketAprobacionEvent, TicketAprobacionState> {
  final TicketAprobacionUseCases useCases;

  TicketAprobacionBloc(this.useCases) : super(const TicketAprobacionState()) {
    on<LoadTicketsSolicitados>(_onLoadTicketsSolicitados);
    on<AprobarTicketEvent>(_onAprobarTicket);
    on<RechazarTicketEvent>(_onRechazarTicket);
    on<ToggleTicketSelection>(_onToggleTicketSelection);
    on<SelectAllTickets>(_onSelectAllTickets);
    on<DeselectAllTickets>(_onDeselectAllTickets);
    on<ResetAprobacionState>(_onResetAprobacionState);
  }

  Future<void> _onLoadTicketsSolicitados(LoadTicketsSolicitados event,Emitter<TicketAprobacionState> emit,) async {
    if (kDebugMode) {
      print('📋 [TicketAprobacionBloc] Cargando tickets solicitados...');
    }

    emit(state.copyWith(ticketsResponse: Loading()));

    final response = await useCases.getTicketsSolicitados.run();

    if (response is Success<List<TicketAbastecimiento>>) {
      if (kDebugMode) {
        print('✅ [TicketAprobacionBloc] ${response.data.length} tickets cargados');
      }

      emit(state.copyWith(
        ticketsResponse: response,
        tickets: response.data,
        selectedTicketIds: {}, // Limpiar selección
      ));
    } else if (response is Error) {
      final error = response as Error;
      if (kDebugMode) {
      print('❌ [TicketAprobacionBloc] Error: ${error.message}');
    }

      emit(state.copyWith(ticketsResponse: response));
    }
  }

  Future<void> _onAprobarTicket(
    AprobarTicketEvent event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    if (kDebugMode) {
      print('✅ [TicketAprobacionBloc] Aprobando ticket: ${event.ticketId}');
    }

    emit(state.copyWith(aprobarResponse: Loading()));

    final response = await useCases.aprobarTicket.run(
      ticketId: event.ticketId,
      aprobadoPorId: event.aprobadoPorId,
    );

    if (response is Success) {
      if (kDebugMode) {
        print('✅ [TicketAprobacionBloc] Ticket aprobado exitosamente');
      }

      emit(state.copyWith(aprobarResponse: response));

      // Recargar lista de tickets
      add(const LoadTicketsSolicitados());
    } else if (response is Error) {
      final error = response as Error;
      if (kDebugMode) {
        print('❌ [TicketAprobacionBloc] Error al aprobar: ${error.message}');
      }

      emit(state.copyWith(aprobarResponse: response));
    }
  }

  Future<void> _onRechazarTicket(
    RechazarTicketEvent event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    if (kDebugMode) {
      print('❌ [TicketAprobacionBloc] Rechazando ticket: ${event.ticketId}');
    }

    emit(state.copyWith(rechazarResponse: Loading()));

    final response = await useCases.rechazarTicket.run(
      ticketId: event.ticketId,
      rechazadoPorId: event.rechazadoPorId,
      motivo: event.motivo,
    );

    if (response is Success) {
      if (kDebugMode) {
        print('✅ [TicketAprobacionBloc] Ticket rechazado exitosamente');
      }

      emit(state.copyWith(rechazarResponse: response));

      // Recargar lista de tickets
      add(const LoadTicketsSolicitados());
    } else if (response is Error) {
      final error = response as Error;
      if (kDebugMode) {
        print('❌ [TicketAprobacionBloc] Error al rechazar: ${error.message}');
      }

      emit(state.copyWith(rechazarResponse: response));
    }
  }

  Future<void> _onToggleTicketSelection(
    ToggleTicketSelection event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    final selectedIds = Set<int>.from(state.selectedTicketIds);

    if (selectedIds.contains(event.ticketId)) {
      selectedIds.remove(event.ticketId);
    } else {
      selectedIds.add(event.ticketId);
    }

    emit(state.copyWith(selectedTicketIds: selectedIds));
  }

  Future<void> _onSelectAllTickets(
    SelectAllTickets event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    final allIds = state.tickets.map((t) => t.id).toSet();
    emit(state.copyWith(selectedTicketIds: allIds));
  }

  Future<void> _onDeselectAllTickets(
    DeselectAllTickets event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    emit(state.copyWith(selectedTicketIds: {}));
  }

  Future<void> _onResetAprobacionState(
    ResetAprobacionState event,
    Emitter<TicketAprobacionState> emit,
  ) async {
    emit(const TicketAprobacionState());
  }
}
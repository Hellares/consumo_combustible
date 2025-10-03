import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketUseCases ticketUseCases;

  TicketBloc(this.ticketUseCases) : super(const TicketState()) {
    on<CreateTicket>(_onCreateTicket);
    on<ResetTicketState>(_onResetTicketState);
  }

  Future<void> _onCreateTicket(CreateTicket event, Emitter emit) async {
    emit(state.copyWith(createResponse: Loading()));

    final response = await ticketUseCases.createTicket.run(event.request);

    emit(state.copyWith(createResponse: response));
  }

  Future<void> _onResetTicketState(ResetTicketState event, Emitter emit) async {
    emit(const TicketState());
  }
}
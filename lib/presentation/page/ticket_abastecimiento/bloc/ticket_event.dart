import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  const TicketEvent();
}

class CreateTicket extends TicketEvent {
  final CreateTicketRequest request;
  const CreateTicket(this.request);
  
  @override
  List<Object?> get props => [request];
}

class ResetTicketState extends TicketEvent {
  const ResetTicketState();
  
  @override
  List<Object?> get props => [];
}
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

/// Evento para cargar unidades por zona
class LoadUnidadesByZona extends TicketEvent {
  final int zonaId;

  const LoadUnidadesByZona(this.zonaId);

  @override
  List<Object?> get props => [zonaId];
}

///  Evento para resetear solo las unidades
class ResetUnidades extends TicketEvent {
  const ResetUnidades();

  @override
  List<Object?> get props => [];
}
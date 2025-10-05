import 'package:equatable/equatable.dart';

abstract class TicketAprobacionEvent extends Equatable {
  const TicketAprobacionEvent();
}

/// Cargar tickets solicitados
class LoadTicketsSolicitados extends TicketAprobacionEvent {
  const LoadTicketsSolicitados();

  @override
  List<Object?> get props => [];
}

/// Aprobar ticket
class AprobarTicketEvent extends TicketAprobacionEvent {
  final int ticketId;
  final int aprobadoPorId;

  const AprobarTicketEvent({
    required this.ticketId,
    required this.aprobadoPorId,
  });

  @override
  List<Object?> get props => [ticketId, aprobadoPorId];
}

/// Rechazar ticket
class RechazarTicketEvent extends TicketAprobacionEvent {
  final int ticketId;
  final int rechazadoPorId;
  final String motivo;

  const RechazarTicketEvent({
    required this.ticketId,
    required this.rechazadoPorId,
    required this.motivo,
  });

  @override
  List<Object?> get props => [ticketId, rechazadoPorId, motivo];
}

/// Seleccionar/Deseleccionar ticket
class ToggleTicketSelection extends TicketAprobacionEvent {
  final int ticketId;

  const ToggleTicketSelection(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

/// Seleccionar todos
class SelectAllTickets extends TicketAprobacionEvent {
  const SelectAllTickets();

  @override
  List<Object?> get props => [];
}

/// Deseleccionar todos
class DeselectAllTickets extends TicketAprobacionEvent {
  const DeselectAllTickets();

  @override
  List<Object?> get props => [];
}

/// Resetear estado
class ResetAprobacionState extends TicketAprobacionEvent {
  const ResetAprobacionState();

  @override
  List<Object?> get props => [];
}
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class TicketAprobacionState extends Equatable {
  final Resource? ticketsResponse;
  final List<TicketAbastecimiento> tickets;
  final Set<int> selectedTicketIds; // IDs de tickets seleccionados
  final Resource? aprobarResponse;
  final Resource? rechazarResponse;

  const TicketAprobacionState({
    this.ticketsResponse,
    this.tickets = const [],
    this.selectedTicketIds = const {},
    this.aprobarResponse,
    this.rechazarResponse,
  });

  TicketAprobacionState copyWith({
    Resource? ticketsResponse,
    List<TicketAbastecimiento>? tickets,
    Set<int>? selectedTicketIds,
    Resource? aprobarResponse,
    Resource? rechazarResponse,
  }) {
    return TicketAprobacionState(
      ticketsResponse: ticketsResponse ?? this.ticketsResponse,
      tickets: tickets ?? this.tickets,
      selectedTicketIds: selectedTicketIds ?? this.selectedTicketIds,
      aprobarResponse: aprobarResponse ?? this.aprobarResponse,
      rechazarResponse: rechazarResponse ?? this.rechazarResponse,
    );
  }

  @override
  List<Object?> get props => [
        ticketsResponse,
        tickets,
        selectedTicketIds,
        aprobarResponse,
        rechazarResponse,
      ];

  // Helpers
  bool get isLoadingTickets => ticketsResponse is Loading;
  bool get hasTickets => tickets.isNotEmpty;
  bool get hasSelectedTickets => selectedTicketIds.isNotEmpty;
  int get selectedCount => selectedTicketIds.length;
  bool get isAllSelected => 
      tickets.isNotEmpty && selectedTicketIds.length == tickets.length;
  
  bool isTicketSelected(int ticketId) => selectedTicketIds.contains(ticketId);
}
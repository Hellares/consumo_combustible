import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_state.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/widgets/aprobar_ticket_dialog.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/widgets/rechazar_ticket_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketsAprobacionPage extends StatefulWidget {
  const TicketsAprobacionPage({super.key});

  @override
  State<TicketsAprobacionPage> createState() => _TicketsAprobacionPageState();
}

class _TicketsAprobacionPageState extends State<TicketsAprobacionPage> {
  late final TicketAprobacionBloc _bloc;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TicketAprobacionBloc>();
    _loadUserSession();
    _bloc.add(const LoadTicketsSolicitados());
  }

  Future<void> _loadUserSession() async {
    final authUseCases = locator<AuthUseCases>();
    final session = await authUseCases.getUserSession.run();
    if (session?.data?.user != null) {
      setState(() => _currentUserId = session!.data!.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprobación de Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _bloc.add(const LoadTicketsSolicitados()),
          ),
        ],
      ),
      body: BlocConsumer<TicketAprobacionBloc, TicketAprobacionState>(
        bloc: _bloc,
        listener: (context, state) {
          // Listener para aprobación exitosa
          if (state.aprobarResponse is Success) {
            SnackBarHelper.showSuccess(context, 'Ticket aprobado exitosamente');
            _bloc.add(const ResetAprobacionState());
          } else if (state.aprobarResponse is Error) {
            final error = state.aprobarResponse as Error;
            SnackBarHelper.showError(context, error.message);
          }

          // Listener para rechazo exitoso
          if (state.rechazarResponse is Success) {
            SnackBarHelper.showSuccess(context, 'Ticket rechazado');
            _bloc.add(const ResetAprobacionState());
          } else if (state.rechazarResponse is Error) {
            final error = state.rechazarResponse as Error;
            SnackBarHelper.showError(context, error.message);
          }
        },
        builder: (context, state) {
          if (state.isLoadingTickets) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.hasTickets) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No hay tickets pendientes',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header con selección
              _buildSelectionHeader(state),

              // Lista de tickets
              Expanded(
                child: ListView.builder(
                  itemCount: state.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = state.tickets[index];
                    final isSelected = state.isTicketSelected(ticket.id);
                    return _buildTicketCard(ticket, isSelected);
                  },
                ),
              ),

              // Bottom bar con acciones
              if (state.hasSelectedTickets) _buildActionBar(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectionHeader(TicketAprobacionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          Checkbox(
            value: state.isAllSelected,
            onChanged: (value) {
              if (value == true) {
                _bloc.add(const SelectAllTickets());
              } else {
                _bloc.add(const DeselectAllTickets());
              }
            },
          ),
          Expanded(
            child: Text(
              state.hasSelectedTickets
                  ? '${state.selectedCount} seleccionado(s)'
                  : 'Seleccionar todos',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          if (state.hasSelectedTickets)
            TextButton(
              onPressed: () => _bloc.add(const DeselectAllTickets()),
              child: const Text('Limpiar'),
            ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketAbastecimiento ticket, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isSelected ? Colors.blue.shade50 : null,
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
          onChanged: (value) {
            _bloc.add(ToggleTicketSelection(ticket.id));
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                ticket.numeroTicket,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ticket.estado.colorValue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ticket.estado.nombre,
                style: TextStyle(
                  fontSize: 11,
                  color: ticket.estado.colorValue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.local_shipping, size: 14),
                const SizedBox(width: 4),
                Text('${ticket.unidad.placa} - ${ticket.unidad.marca}'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.local_gas_station, size: 14),
                const SizedBox(width: 4),
                Text('${ticket.cantidad} gal - ${ticket.grifo.nombre}'),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.person, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${ticket.solicitadoPor.nombres} ${ticket.solicitadoPor.apellidos}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () => _aprobarTicket(ticket),
              tooltip: 'Aprobar',
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () => _rechazarTicket(ticket),
              tooltip: 'Rechazar',
            ),
          ],
        ),
        onTap: () => _verDetalleTicket(ticket),
      ),
    );
  }

  Widget _buildActionBar(TicketAprobacionState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _aprobarSeleccionados(state),
              icon: const Icon(Icons.check),
              label: Text('Aprobar (${state.selectedCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _rechazarSeleccionados(state),
              icon: const Icon(Icons.close),
              label: Text('Rechazar (${state.selectedCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _aprobarTicket(TicketAbastecimiento ticket) async {
    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'Sesión no válida');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AprobarTicketDialog(ticket: ticket),
    );

    if (confirmed == true) {
      _bloc.add(AprobarTicketEvent(
        ticketId: ticket.id,
        aprobadoPorId: _currentUserId!,
      ));
    }
  }

  Future<void> _aprobarSeleccionados(TicketAprobacionState state) async {
    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'Sesión no válida');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Tickets'),
        content: Text(
          '¿Aprobar ${state.selectedCount} ticket(s) seleccionado(s)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (final ticketId in state.selectedTicketIds) {
        _bloc.add(AprobarTicketEvent(
          ticketId: ticketId,
          aprobadoPorId: _currentUserId!,
        ));
      }
    }
  }

  Future<void> _rechazarTicket(TicketAbastecimiento ticket) async {
    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'Sesión no válida');
      return;
    }

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => RechazarTicketDialog(ticket: ticket),
    );

    if (motivo != null && motivo.isNotEmpty) {
      _bloc.add(RechazarTicketEvent(
        ticketId: ticket.id,
        rechazadoPorId: _currentUserId!,
        motivo: motivo,
      ));
    }
  }

  Future<void> _rechazarSeleccionados(TicketAprobacionState state) async {
    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'Sesión no válida');
      return;
    }

    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => _buildMotivoRechazoDialog(state.selectedCount),
    );

    if (motivo != null && motivo.isNotEmpty) {
      for (final ticketId in state.selectedTicketIds) {
        _bloc.add(RechazarTicketEvent(
          ticketId: ticketId,
          rechazadoPorId: _currentUserId!,
          motivo: motivo,
        ));
      }
    }
  }

  Widget _buildMotivoRechazoDialog(int count) {
    final controller = TextEditingController();

    return AlertDialog(
      title: Text('Rechazar $count Ticket(s)'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Motivo del rechazo *',
          border: OutlineInputBorder(),
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Rechazar'),
        ),
      ],
    );
  }

  void _verDetalleTicket(TicketAbastecimiento ticket) {
    // Implementar navegación a detalle
  }
}
// lib/presentation/page/ticket_aprobacion/tickets_aprobacion_page.dart

import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_state.dart';
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
          // Listener para aprobación en lote
          if (state.aprobarResponse is Success<Map<String, dynamic>>) {
            final data = (state.aprobarResponse as Success<Map<String, dynamic>>).data;
            final exitosos = data['exitosos'] ?? 0;
            final fallidos = data['fallidos'] ?? 0;
            
            if (fallidos == 0) {
              SnackBarHelper.showSuccess(
                context, 
                '$exitosos ticket(s) aprobado(s) exitosamente'
              );
            } else {
              SnackBarHelper.showWarning(
                context,
                '$exitosos exitosos, $fallidos fallidos. Revisa los errores.'
              );
            }
            
            _bloc.add(const ResetAprobacionState());
          } else if (state.aprobarResponse is Error) {
            final error = state.aprobarResponse as Error;
            SnackBarHelper.showError(context, error.message);
            _bloc.add(const ResetAprobacionState());
          }

          // Listener para rechazo exitoso
          if (state.rechazarResponse is Success) {
            SnackBarHelper.showSuccess(context, 'Ticket rechazado');
            _bloc.add(const ResetAprobacionState());
          } else if (state.rechazarResponse is Error) {
            final error = state.rechazarResponse as Error;
            SnackBarHelper.showError(context, error.message);
            _bloc.add(const ResetAprobacionState());
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
              _buildSelectionHeader(state),
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
            TextButton.icon(
              onPressed: () => _bloc.add(const DeselectAllTickets()),
              icon: const Icon(Icons.clear, size: 18),
              label: const Text('Limpiar'),
            ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketAbastecimiento ticket, bool isSelected) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: () => _verDetalleTicket(ticket),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  _bloc.add(ToggleTicketSelection(ticket.id));
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.numeroTicket,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('Unidad: ${ticket.unidad.placa}'),
                    Text('Conductor: ${ticket.conductor.nombres} ${ticket.conductor.apellidos}'),
                    Text('Cantidad: ${ticket.cantidad} gal'),
                    Text('Fecha: ${ticket.fecha}'),
                  ],
                ),
              ),
              Column(
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
            ],
          ),
        ),
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
              onPressed: state.aprobarResponse is Loading 
                ? null 
                : () => _aprobarSeleccionados(state),
              icon: state.aprobarResponse is Loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: Text('Aprobar (${state.selectedCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.rechazarResponse is Loading
                ? null
                : () => _rechazarSeleccionados(state),
              icon: const Icon(Icons.cancel),
              label: Text('Rechazar (${state.selectedCount})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
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
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Ticket'),
        content: Text('¿Confirmas la aprobación del ticket ${ticket.numeroTicket}?'),
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
        title: Text('Aprobar ${state.selectedCount} Ticket(s)'),
        content: Text(
          '¿Confirmas la aprobación de ${state.selectedCount} ticket(s) seleccionado(s)?'
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
      _bloc.add(AprobarTicketsLoteEvent(
        ticketIds: state.selectedTicketIds.toList(),
        aprobadoPorId: _currentUserId!,
      ));
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
    // TODO: Implementar navegación a detalle
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket.numeroTicket),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Unidad', ticket.unidad.placa),
              _buildDetailRow('Conductor', '${ticket.conductor.nombres} ${ticket.conductor.apellidos}'),
              _buildDetailRow('Grifo', ticket.grifo.nombre),
              _buildDetailRow('Cantidad', '${ticket.cantidad} gal'),
              _buildDetailRow('Km Actual', ticket.kilometrajeActual.toString()),
              if (ticket.kilometrajeAnterior != null)
                _buildDetailRow('Km Anterior', ticket.kilometrajeAnterior.toString()),
              _buildDetailRow('Precinto', ticket.precintoNuevo),
              _buildDetailRow('Fecha', ticket.fecha),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
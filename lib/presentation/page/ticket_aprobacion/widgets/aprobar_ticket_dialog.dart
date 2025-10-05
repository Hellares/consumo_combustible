import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:flutter/material.dart';

class AprobarTicketDialog extends StatelessWidget {
  final TicketAbastecimiento ticket;

  const AprobarTicketDialog({
    super.key,
    required this.ticket,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade700),
          const SizedBox(width: 12),
          const Text('Aprobar Ticket'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmar la aprobación del siguiente ticket?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Información del ticket
            _buildInfoSection(
              'Ticket',
              [
                _buildInfoRow('Número:', ticket.numeroTicket),
                _buildInfoRow('Fecha:', '${ticket.fecha} ${ticket.hora}'),
              ],
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              'Unidad',
              [
                _buildInfoRow('Placa:', ticket.unidad.placa),
                _buildInfoRow(
                  'Vehículo:',
                  '${ticket.unidad.marca} ${ticket.unidad.modelo}',
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              'Abastecimiento',
              [
                _buildInfoRow(
                  'Cantidad:',
                  '${ticket.cantidad} gal',
                  valueColor: Colors.green.shade700,
                ),
                _buildInfoRow('Kilometraje:', '${ticket.kilometrajeActual} km'),
                _buildInfoRow('Precinto:', ticket.precintoNuevo),
              ],
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              'Ubicación',
              [
                _buildInfoRow('Grifo:', ticket.grifo.nombre),
              ],
            ),
            const SizedBox(height: 12),

            _buildInfoSection(
              'Solicitante',
              [
                _buildInfoRow(
                  'Conductor:',
                  '${ticket.solicitadoPor.nombres} ${ticket.solicitadoPor.apellidos}',
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.green.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Al aprobar, se generará el registro de abastecimiento',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Aprobar'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
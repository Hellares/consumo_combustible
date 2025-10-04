// lib/presentation/page/ticket_abastecimiento/widgets/ticket_confirmation_dialog.dart

import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:flutter/material.dart';

class TicketConfirmationDialog extends StatelessWidget {
  final Unidad unidad;
  final SelectedLocation location;
  final double kilometraje;
  final String precinto;
  final double cantidad;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const TicketConfirmationDialog({
    super.key,
    required this.unidad,
    required this.location,
    required this.kilometraje,
    required this.precinto,
    required this.cantidad,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Text('Confirmar Ticket'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de crear este ticket con los siguientes datos?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Sección: Unidad
            _buildSectionTitle('Unidad'),
            _buildInfoCard(
              icon: Icons.local_shipping,
              color: Colors.orange,
              items: [
                _buildInfoRow('Placa:', unidad.placa),
                _buildInfoRow('Marca:', '${unidad.marca} ${unidad.modelo}'),
                _buildInfoRow('Año:', unidad.anio.toString()),
                _buildInfoRow('Tipo:', unidad.tipoCombustible),
                _buildInfoRow('Capacidad:', '${unidad.capacidadTanque} gal'),
              ],
            ),
            const SizedBox(height: 16),

            // Sección: Datos del Abastecimiento
            _buildSectionTitle('Abastecimiento'),
            _buildInfoCard(
              icon: Icons.local_gas_station,
              color: Colors.blue,
              items: [
                _buildInfoRow('Kilometraje:', '$kilometraje km'),
                _buildInfoRow('Precinto:', precinto),
                _buildInfoRow(
                  'Cantidad:',
                  '$cantidad gal',
                  valueColor: Colors.green.shade700,
                  isBold: true,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sección: Ubicación
            _buildSectionTitle('Ubicación'),
            _buildInfoCard(
              icon: Icons.location_on,
              color: Colors.red,
              items: [
                _buildInfoRow('Grifo:', location.grifo.nombre),
                _buildInfoRow('Sede:', location.sede.nombre),
                _buildInfoRow('Zona:', location.zona.nombre),
              ],
            ),

            // Advertencia si cantidad excede capacidad
            if (cantidad > unidad.capacidadTanque) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La cantidad excede la capacidad del tanque (${unidad.capacidadTanque} gal)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
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
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
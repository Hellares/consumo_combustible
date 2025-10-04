// lib/core/widgets/location_header_widget.dart

import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar la ubicación actual con opción de cambiar
class LocationHeaderWidget extends StatelessWidget {
  final SelectedLocation location;
  final VoidCallback? onChangeLocation;
  final bool showChangeButton;

  const LocationHeaderWidget({
    super.key,
    required this.location,
    this.onChangeLocation,
    this.showChangeButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ubicación Actual',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
                if (showChangeButton && onChangeLocation != null)
                  InkWell(
                    onTap: onChangeLocation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_location,
                            size: 16,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Cambiar',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.local_gas_station,
              label: 'Grifo',
              value: location.grifo.nombre,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.location_city,
              label: 'Dirección',
              value: location.grifo.direccion,
              isSmall: true,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.business,
              label: 'Sede',
              value: location.sede.nombre,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.map,
              label: 'Zona',
              value: location.zona.nombre,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isSmall = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 12 : 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
}
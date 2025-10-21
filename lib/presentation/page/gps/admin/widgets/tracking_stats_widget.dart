// =============================================
// Tracking Stats Widget
// Widget con estadísticas generales
// =============================================

import 'package:flutter/material.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';

class TrackingStatsWidget extends StatelessWidget {
  final List<UnidadTracking> unidades;

  const TrackingStatsWidget({
    super.key,
    required this.unidades,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.directions_car,
            label: 'Total',
            value: stats['total'].toString(),
            color: Colors.blue,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'Activas',
            value: stats['activas'].toString(),
            color: Colors.green.shade700,
          ),
          _buildStatItem(
            icon: Icons.speed,
            label: 'En Movimiento',
            value: stats['enMovimiento'].toString(),
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.pause_circle,
            label: 'Detenidas',
            value: stats['detenidas'].toString(),
            color: Colors.orange,
          ),
          _buildStatItem(
            icon: Icons.signal_wifi_off,
            label: 'Inactivas',
            value: stats['inactivas'].toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Map<String, int> _calculateStats() {
    // En movimiento = unidades con estado activo (velocidad > umbral)
    final enMovimiento = unidades.where((u) => u.isMoving).length;
    
    // Detenidas = unidades con ubicación reciente pero sin movimiento
    final detenidas = unidades.where((u) => u.isStopped).length;
    
    // Activas = suma de en movimiento + detenidas (todas con GPS activo)
    final activas = enMovimiento + detenidas;
    
    // Inactivas = unidades sin señal GPS (sin ubicación reciente)
    final inactivas = unidades.where((u) => u.isInactive).length;

    return {
      'total': unidades.length,
      'activas': activas,
      'enMovimiento': enMovimiento,
      'detenidas': detenidas,
      'inactivas': inactivas,
    };
  }
}
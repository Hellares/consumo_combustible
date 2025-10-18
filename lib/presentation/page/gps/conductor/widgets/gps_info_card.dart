// =============================================
// GPS Info Card
// Tarjeta con información de GPS
// =============================================

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:consumo_combustible/core/services/location_gps_service.dart';

class GpsInfoCard extends StatelessWidget {
  final Position? position;
  final int locationsSent;
  final DateTime? lastLocationSentAt;

  const GpsInfoCard({
    super.key,
    this.position,
    this.locationsSent = 0,
    this.lastLocationSentAt,
  });

  @override
  Widget build(BuildContext context) {
    final locationService = LocationGpsService();

    return Card(
      color: AppColors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información GPS',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.blue3
                  ),
            ),
            const SizedBox(height: 10),
            if (position != null) ...[
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Latitud',
                value: position!.latitude.toStringAsFixed(6),
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Longitud',
                value: position!.longitude.toStringAsFixed(6),
                color: Colors.blue,
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                icon: Icons.speed,
                label: 'Velocidad',
                value: '${locationService.metersPerSecondToKmh(position!.speed).toStringAsFixed(1)} km/h',
                color: Colors.green,
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                icon: Icons.signal_cellular_alt,
                label: 'Precisión',
                value: '${position!.accuracy.toStringAsFixed(1)}m (${locationService.getAccuracyLabel(position!.accuracy)})',
                color: _getAccuracyColor(position!.accuracy),
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                icon: Icons.explore,
                label: 'Rumbo',
                value: '${position!.heading.toStringAsFixed(0)}°',
                color: Colors.purple,
              ),
              const SizedBox(height: 5),
              _buildInfoRow(
                icon: Icons.terrain,
                label: 'Altitud',
                value: '${position!.altitude.toStringAsFixed(1)}m',
                color: Colors.orange,
              ),
              const Divider(height: 15),
              _buildInfoRow(
                icon: Icons.send,
                label: 'Ubicaciones enviadas',
                value: locationsSent.toString(),
                color: Colors.indigo,
                
              ),
              if (lastLocationSentAt != null) ...[
                const SizedBox(height: 5),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Última actualización',
                  value: _getTimeSince(lastLocationSentAt!),
                  color: Colors.grey,
                ),
              ],
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Esperando ubicación GPS...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 10) return Colors.green;
    if (accuracy < 20) return Colors.lightGreen;
    if (accuracy < 50) return Colors.orange;
    return Colors.red;
  }

  String _getTimeSince(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return 'Hace ${diff.inSeconds}s';
    } else if (diff.inMinutes < 60) {
      return 'Hace ${diff.inMinutes}min';
    } else {
      return 'Hace ${diff.inHours}h';
    }
  }
}
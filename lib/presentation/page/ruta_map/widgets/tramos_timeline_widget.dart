// lib/presentation/page/ruta_map/widgets/tramos_timeline_widget.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:flutter/material.dart';

class TramosTimelineWidget extends StatelessWidget {
  final List<TramoItinerario> tramos;

  const TramosTimelineWidget({
    super.key,
    required this.tramos,
  });

  @override
  Widget build(BuildContext context) {
    if (tramos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: AppColors.blue3,
                size: 18,
              ),
              const SizedBox(width: 8),
              AppSubtitle(
                'Tramos del Itinerario',
                fontSize: 12,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blue3.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${tramos.length} tramos',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blue3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Timeline de tramos
          ...tramos.asMap().entries.map((entry) {
            final index = entry.key;
            final tramo = entry.value;
            final isLast = index == tramos.length - 1;

            return _buildTramoItem(tramo, isLast);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTramoItem(TramoItinerario tramo, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline vertical
          SizedBox(
            width: 30,
            child: Column(
              children: [
                // Número del tramo
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.blue3,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${tramo.orden}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Línea conectora
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.blue3.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Información del tramo
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.blue3.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origen → Destino
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.blue3,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${tramo.ciudadOrigen} → ${tramo.ciudadDestino}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Distancia y tiempo
                  Row(
                    children: [
                      Icon(Icons.straighten, size: 10, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${tramo.ruta.distanciaKm.toStringAsFixed(1)} km',
                        style: TextStyle(fontSize: 8, color: Colors.grey[700]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time, size: 10, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${tramo.ruta.tiempoEstimadoMinutos} min',
                        style: TextStyle(fontSize: 8, color: Colors.grey[700]),
                      ),
                    ],
                  ),

                  // Badges de características
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (tramo.requiereAbastecimiento)
                        _buildBadge('⛽ Abastecimiento', Colors.orange),
                      if (tramo.requiereInspeccion)
                        _buildBadge('🔍 Inspección', Colors.blue),
                      if (tramo.esParadaObligatoria)
                        _buildBadge('🛑 Parada obligatoria', Colors.red),
                    ],
                  ),

                  // Punto de parada
                  if (tramo.puntoParada != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.place, size: 10, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            tramo.puntoParada!,
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
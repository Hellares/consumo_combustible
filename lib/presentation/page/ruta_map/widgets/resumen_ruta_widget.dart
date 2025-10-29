// lib/presentation/page/ruta_map/widgets/resumen_ruta_widget.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/mapa_ruta_data.dart';
import 'package:flutter/material.dart';

class ResumenRutaWidget extends StatelessWidget {
  final MapaRutaData data;

  const ResumenRutaWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
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
                data.esItinerario ? Icons.route : Icons.directions,
                color: AppColors.blue3,
                size: 18,
              ),
              const SizedBox(width: 8),
              AppSubtitle(
                data.esItinerario ? 'Resumen del Itinerario' : 'Resumen de la Ruta',
                fontSize: 12,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Información
          if (data.esItinerario && data.itinerario != null) ...[
            _buildInfoRow(
              Icons.label,
              'Nombre',
              data.itinerario!.nombre,
            ),
            _buildDivider(),
            _buildInfoRow(
              Icons.qr_code_2,
              'Código',
              data.itinerario!.codigo,
            ),
            _buildDivider(),
            _buildInfoRow(
              Icons.compare_arrows,
              'Tipo',
              _formatTipoItinerario(data.itinerario!.tipoItinerario),
            ),
          ] else if (data.esRutaSimple && data.ruta != null) ...[
            _buildInfoRow(
              Icons.label,
              'Nombre',
              data.ruta!.nombre,
            ),
            ...[
            _buildDivider(),
            _buildInfoRow(
              Icons.qr_code_2,
              'Código',
              data.ruta!.codigo,
            ),
          ],
            _buildDivider(),
            _buildInfoRow(
              Icons.route,
              'Trayecto',
              '${data.ruta!.origen} → ${data.ruta!.destino}',
            ),
          ],

          _buildDivider(),

          // Distancia
          if (data.distanciaTotal != null)
            _buildInfoRow(
              Icons.straighten,
              'Distancia Total',
              '${data.distanciaTotal!.toStringAsFixed(1)} km',
              valueColor: AppColors.blue3,
            ),

          _buildDivider(),

          // Tiempo estimado
          if (data.tiempoEstimadoTotal != null)
            _buildInfoRow(
              Icons.access_time,
              'Tiempo Estimado',
              _formatTiempo(data.tiempoEstimadoTotal!),
              valueColor: AppColors.blue3,
            ),

          _buildDivider(),

          // Cantidad de tramos
          _buildInfoRow(
            Icons.alt_route,
            data.esItinerario ? 'Tramos' : 'Segmentos',
            '${data.cantidadTramos}',
            valueColor: AppColors.blue3,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: AppLabelText(
            label,
            fontSize: 9,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: AppSubtitle(
            value,
            fontSize: 10,
            color: valueColor ?? Colors.black87,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        color: Colors.grey[300],
      ),
    );
  }

  String _formatTipoItinerario(String tipo) {
    switch (tipo) {
      case 'CIRCULAR':
        return 'Circular';
      case 'IDA_VUELTA':
        return 'Ida y Vuelta';
      case 'LINEAL':
        return 'Lineal';
      default:
        return tipo;
    }
  }

  String _formatTiempo(int minutos) {
    if (minutos < 60) {
      return '$minutos min';
    }

    final horas = minutos ~/ 60;
    final mins = minutos % 60;

    if (mins == 0) {
      return '$horas h';
    }

    return '$horas h ${mins} min';
  }
}
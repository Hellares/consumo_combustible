// lib/presentation/page/reportes/widgets/resumen_card.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumenCard extends StatelessWidget {
  final ResumenReporteResponse resumen;

  const ResumenCard({
    super.key,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    final resumenData = resumen.resumen;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.blue3,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTitle(
                    'Resumen del Sistema',
                    fontSize: 10,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),

          // Estadísticas en grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.local_gas_station,
                        label: 'Abastecimientos',
                        value: _formatNumber(resumenData.totalAbastecimientos),
                        color: AppColors.blue3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.directions_car,
                        label: 'Unidades',
                        value: _formatNumber(resumenData.totalUnidades),
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.store,
                        label: 'Grifos',
                        value: _formatNumber(resumenData.totalGrifos),
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.calendar_today,
                        label: 'Periodo',
                        value: _getPeriodo(
                          resumenData.fechaPrimerRegistro,
                          resumenData.fechaUltimoRegistro,
                        ),
                        color: AppColors.blue3,
                        isSmallText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Item individual de estadística
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmallText = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppFont.oxygenBold.style(
                    fontSize: 10,
                    color: AppColors.blue3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppFont.oxygenBold.style(
              fontSize: 9,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Formatear número con separador de miles
  String _formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'es_ES');
    return formatter.format(number);
  }

  /// Obtener periodo de fechas
  String _getPeriodo(DateTime? inicio, DateTime? fin) {
    if (inicio == null || fin == null) {
      return 'Sin datos';
    }

    final dateFormat = DateFormat('dd/MM/yy');
    return '${dateFormat.format(inicio)} - ${dateFormat.format(fin)}';
  }
}
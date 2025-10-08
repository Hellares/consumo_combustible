// lib/presentation/page/licencias/widgets/licencia_card.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LicenciaCard extends StatelessWidget {
  final LicenciaConducir licencia;
  final VoidCallback? onTap;

  const LicenciaCard({
    super.key,
    required this.licencia,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Usuario y estado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSubtitle(
                          licencia.nombreCompleto,
                          fontSize: 12,
                          color: AppColors.blue3,
                        ),
                        const SizedBox(height: 4),
                        AppCaption(
                          'DNI: ${licencia.usuario.dni} • ${licencia.usuario.codigoEmpleado}',
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  ),
                  _buildEstadoBadge(),
                ],
              ),

              const Divider(height: 24),

              // Información de la licencia
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.credit_card,
                      label: 'Número',
                      value: licencia.numeroLicencia,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.category,
                      label: 'Categoría',
                      value: licencia.categoria,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Fechas
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.date_range,
                      label: 'Emitida',
                      value: _formatDate(licencia.fechaEmision),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.event_busy,
                      label: 'Vence',
                      value: _formatDate(licencia.fechaExpiracion),
                      valueColor: _getVencimientoColor(),
                    ),
                  ),
                ],
              ),

              // Días restantes / Alerta
              if (licencia.requiereAtencion) ...[
                const SizedBox(height: 12),
                _buildAlertaBanner(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstadoBadge() {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (licencia.estadoVigencia) {
      case 'VIGENTE':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.check_circle;
        break;
      case 'PROXIMA_VENCIMIENTO':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.warning_amber;
        break;
      case 'VENCIDA':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help_outline;
    }

    return Container(
      height: 25,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            licencia.estadoVigencia.replaceAll('_', ' '),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.blue3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertaBanner() {
    String mensaje;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (licencia.estaVencida) {
      mensaje = 'Licencia VENCIDA hace ${licencia.diasRestantes.abs()} días';
      backgroundColor = Colors.red[50]!;
      textColor = Colors.red[800]!;
      icon = Icons.error_outline;
    } else {
      mensaje = 'Vence en ${licencia.diasRestantes} días';
      backgroundColor = Colors.orange[50]!;
      textColor = Colors.orange[800]!;
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getVencimientoColor() {
    if (licencia.estaVencida) return Colors.red;
    if (licencia.proximaVencimiento) return Colors.orange;
    return AppColors.blue3;
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
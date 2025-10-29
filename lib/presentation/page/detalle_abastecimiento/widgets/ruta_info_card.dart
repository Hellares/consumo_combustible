// lib/presentation/page/detalle_abastecimiento/widgets/ruta_info_card.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:flutter/material.dart';

class RutaInfoCard extends StatelessWidget {
  final TicketDetalle ticket;
  final VoidCallback onVerRutaPressed;

  const RutaInfoCard({
    super.key,
    required this.ticket,
    required this.onVerRutaPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Verificar si el ticket tiene itinerario o ruta
    final tieneItinerario = ticket.itinerario != null;
    final tieneRuta = ticket.ruta != null;

    // Si no tiene ni itinerario ni ruta, no mostrar el card
    if (!tieneItinerario && !tieneRuta) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.blue3.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.route,
                  color: AppColors.blue3,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSubtitle(
                      tieneItinerario ? 'Itinerario' : 'Ruta',
                      fontSize: 10,
                      // fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 2),
                    AppLabelText(
                      _getTipoAsignacion(),
                      fontSize: 9,
                      color: _getColorAsignacion(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Información del Itinerario o Ruta
          if (tieneItinerario) ...[
            _buildItinerarioInfo(),
          ] else if (tieneRuta) ...[
            _buildRutaInfo(),
          ],

          const SizedBox(height: 16),

          // Botón Ver Ruta en Mapa
          CustomButton(
            height: 35,
            text: 'Ver Ruta en Mapa',
            onPressed: onVerRutaPressed,
            backgroundColor: AppColors.blue3,
          ),
        ],
      ),
    );
  }

  /// Construir información del itinerario
  Widget _buildItinerarioInfo() {
    final itinerario = ticket.itinerario!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.blue3.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre del itinerario
          Row(
            children: [
              Icon(Icons.label, size: 14, color: AppColors.blue3),
              const SizedBox(width: 6),
              Expanded(
                child: AppSubtitle(
                  itinerario.nombre,
                  fontSize: 11,
                  // fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Código
          Row(
            children: [
              Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              AppLabelText(
                'Código: ${itinerario.codigo}',
                fontSize: 9,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Tipo de itinerario
          Row(
            children: [
              Icon(Icons.compare_arrows, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getTipoItinerarioColor(itinerario.tipoItinerario),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatTipoItinerario(itinerario.tipoItinerario),
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Distancia
          if (itinerario.distanciaTotal != null) ...[
            Row(
              children: [
                Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                AppLabelText(
                  'Distancia: ${itinerario.distanciaTotal!.toStringAsFixed(1)} km',
                  fontSize: 9,
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Días de operación
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: itinerario.diasOperacion.map((dia) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: AppColors.blue3.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _formatDia(dia),
                        style: TextStyle(
                          fontSize: 7,
                          color: AppColors.blue3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construir información de la ruta
  Widget _buildRutaInfo() {
    final ruta = ticket.ruta!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre de la ruta
          Row(
            children: [
              Icon(Icons.label, size: 14, color: Colors.green[700]),
              const SizedBox(width: 6),
              Expanded(
                child: AppSubtitle(
                  ruta.nombre,
                  fontSize: 11,
                  // fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Código
          if (ruta.codigo != null) ...[
            Row(
              children: [
                Icon(Icons.qr_code, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                AppLabelText(
                  'Código: ${ruta.codigo}',
                  fontSize: 9,
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Trayecto
          Row(
            children: [
              Icon(Icons.route, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Expanded(
                child: AppLabelText(
                  '${ruta.origen ?? "N/A"} → ${ruta.destino ?? "N/A"}',
                  fontSize: 9,
                  // fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Distancia
          if (ruta.distanciaKm != null) ...[
            Row(
              children: [
                Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                AppLabelText(
                  'Distancia: ${ruta.distanciaKm!} km',
                  fontSize: 9,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Obtener el texto del tipo de asignación
  String _getTipoAsignacion() {
    final origen = ticket.origenAsignacion;
    switch (origen) {
      case 'EJECUCION_ACTIVA':
        return '🟢 Ejecución Activa';
      case 'ITINERARIO_PERMANENTE':
        return '🔵 Itinerario Permanente';
      case 'RUTA_EXCEPCIONAL':
        return '🟠 Ruta Excepcional';
      case 'MANUAL':
        return '⚪ Asignación Manual';
      default:
        return '⚫ Sin Asignación';
    }
  }

  /// Obtener el color según el tipo de asignación
  Color _getColorAsignacion() {
    final origen = ticket.origenAsignacion;
    switch (origen) {
      case 'EJECUCION_ACTIVA':
        return Colors.green[700]!;
      case 'ITINERARIO_PERMANENTE':
        return AppColors.blue3;
      case 'RUTA_EXCEPCIONAL':
        return Colors.orange[700]!;
      case 'MANUAL':
        return Colors.grey[700]!;
      default:
        return Colors.black;
    }
  }

  /// Formatear tipo de itinerario
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

  /// Obtener color según tipo de itinerario
  Color _getTipoItinerarioColor(String tipo) {
    switch (tipo) {
      case 'CIRCULAR':
        return Colors.purple;
      case 'IDA_VUELTA':
        return Colors.blue;
      case 'LINEAL':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Formatear día de la semana
  String _formatDia(String dia) {
    switch (dia) {
      case 'LUNES':
        return 'LUN';
      case 'MARTES':
        return 'MAR';
      case 'MIERCOLES':
        return 'MIÉ';
      case 'JUEVES':
        return 'JUE';
      case 'VIERNES':
        return 'VIE';
      case 'SABADO':
        return 'SÁB';
      case 'DOMINGO':
        return 'DOM';
      default:
        return dia.substring(0, 3);
    }
  }
}
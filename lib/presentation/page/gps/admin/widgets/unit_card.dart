// =============================================
// Unit Card
// Card para mostrar info de unidad en lista
// =============================================

import 'package:flutter/material.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:timeago/timeago.dart' as timeago;

class UnitCard extends StatelessWidget {
  final UnidadTracking unidad;
  final VoidCallback? onTap;
  final bool isSelected;

  const UnitCard({
    super.key,
    required this.unidad,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Colors.blue.shade50 : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Placa y Estado
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: unidad.isActive ? Colors.green : Colors.red,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      unidad.placa,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusIndicator(),
                ],
              ),
              
              const SizedBox(height: 5),
              
              // Velocidad y última actualización
              if (unidad.ultimaUbicacion != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${unidad.ultimaUbicacion!.velocidad?.toStringAsFixed(0) ?? 0} km/h',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                    // const Spacer(),
                    // Icon(
                    //   Icons.access_time,
                    //   size: 16,
                    //   color: Colors.grey[600],
                    // ),
                    // const SizedBox(width: 4),
                    // Text(
                    //   _getTimeAgo(),
                    //   style: TextStyle(
                    //     fontSize: 8,
                    //     color: Colors.grey[600],
                    //   ),
                    // ),
                  ],
                ),
                
                const SizedBox(height: 3),
                
                // Precisión
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 14,
                      color: _getPrecisionColor(),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Precisión: ${unidad.ultimaUbicacion!.precision?.toStringAsFixed(1) ?? 0}m',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: Text(
                        _getTimeAgo(),
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                        ),
                      ),
                ),
              ] else ...[
                Text(
                  'Sin ubicación reciente',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: unidad.isActive ? Colors.green : Colors.red,
        shape: BoxShape.circle,
        boxShadow: unidad.isActive
            ? [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  String _getTimeAgo() {
    if (unidad.ultimaUbicacion?.fechaHora == null) return 'Nunca';
    
    // Configurar locale español (solo se hace una vez)
    timeago.setLocaleMessages('es', timeago.EsMessages());
    
    return timeago.format(
      unidad.ultimaUbicacion!.fechaHora,
      locale: 'es',
      allowFromNow: true,
    );
  }

  Color _getPrecisionColor() {
    final precision = unidad.ultimaUbicacion?.precision ?? 999;
    
    if (precision < 10) return Colors.green;
    if (precision < 20) return Colors.orange;
    return Colors.red;
  }
}
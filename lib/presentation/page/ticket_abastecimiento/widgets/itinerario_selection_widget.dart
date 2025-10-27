// lib/presentation/page/ticket_abastecimiento/widgets/itinerario_selection_widget.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/widgets/seleccionar_itinerario_dialog.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/widgets/seleccionar_ruta_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItinerarioSelectionWidget extends StatelessWidget {
  final Function(int? itinerarioId, int? rutaId, String origenAsignacion, String? motivo, int? itinerarioOriginalId)? onSelectionChanged;

  const ItinerarioSelectionWidget({
    super.key,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, TicketState>(
      builder: (context, state) {
        // 🔄 Mostrando loading mientras detecta
        if (state.isDetectandoItinerario) {
          return _buildLoadingCard();
        }

        // ❌ Mostrar error si falló la detección
        if (state.hasDeteccionError) {
          return _buildErrorCard(context, state.deteccionErrorMessage ?? 'Error desconocido');
        }

        // ✅ Mostrar detección si existe
        if (state.hasDeteccion) {
          return _buildDeteccionCard(context, state.itinerarioDetectado!);
        }

        // ℹ️ Sin detección aún
        return _buildPlaceholderCard();
      },
    );
  }

  /// 🔄 Card de loading
  Widget _buildLoadingCard() {
    return Row(
      children: [
        SizedBox(
          width: 13,
          height: 13,
          child: CircularProgressIndicator(strokeWidth: 1),
        ),
        SizedBox(width: 8),
        Expanded(
          child: AppLabelText(
                  'Detectando itinerario...',
                  font: AppFont.oxygenRegular,
                  fontSize: 9,
                ),
        ),
      ],
    );
  }

  /// ❌ Card de error
  Widget _buildErrorCard(BuildContext context, String message) {
    return Card(
      elevation: 0,
      color: Colors.red[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red[300]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error al detectar',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(fontSize: 12, color: Colors.red[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ℹ️ Card placeholder (sin detección)
  Widget _buildPlaceholderCard() {
    return Card(
      elevation: 1,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400], size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Seleccione una unidad para detectar el itinerario',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Card con la detección
  Widget _buildDeteccionCard(BuildContext context, ItinerarioDetectado deteccion) {
    // Determinar color e icono según el origen
    Color borderColor;
    Color backgroundColor;
    IconData icon;

    switch (deteccion.origen) {
      case 'EJECUCION_ACTIVA':
        borderColor = Colors.green;
        backgroundColor = Colors.green[50]!;
        icon = Icons.play_circle;
        break;
      case 'ITINERARIO_PERMANENTE':
        borderColor = AppColors.blue3;
        backgroundColor = Colors.blue[50]!;
        icon = Icons.calendar_today;
        break;
      case 'RUTA_EXCEPCIONAL':
        borderColor = Colors.orange;
        backgroundColor = Colors.orange[50]!;
        icon = Icons.warning_amber;
        break;
      default:
        borderColor = Colors.grey;
        backgroundColor = Colors.grey[50]!;
        icon = Icons.info_outline;
    }

    return Card(
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono y título
            Row(
              children: [
                Icon(icon, color: borderColor, size: 18),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deteccion.detectado ? 'Detectado automáticamente' : 'Sin asignación',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: borderColor,
                        ),
                      ),
                      Text(
                        deteccion.mensaje,
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Información del itinerario/ruta detectado
            if (deteccion.tieneItinerario) ...[
              SizedBox(height: 10),
              _buildItinerarioInfo(deteccion.itinerario!),
            ],

            if (deteccion.tieneRuta) ...[
              SizedBox(height: 12),
              _buildRutaInfo(deteccion.ruta!),
            ],

            // Botones de acción
            if (deteccion.detectado && deteccion.puedeModificar) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showCambiarItinerarioDialog(context, deteccion),
                      icon: Icon(Icons.edit, size: 16),
                      label: Text('Cambiar Itinerario',style: TextStyle(fontSize: 10),),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: borderColor, width: 0.7),
                        foregroundColor: borderColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showUsarRutaDialog(context, deteccion),
                      icon: Icon(Icons.route, size: 16),
                      label: Text('Usar Ruta',style: TextStyle(fontSize: 10),),
                      style: OutlinedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        side: BorderSide(color: Colors.blue[700]!, width: 0.7),
                        foregroundColor: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Si no hay detección, permitir seleccionar manualmente
            if (!deteccion.detectado) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSeleccionarItinerarioDialog(context, deteccion),
                      icon: Icon(Icons.add, size: 16),
                      label: Text('Asignar Itinerario',style: TextStyle(fontSize: 10),),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showSeleccionarRutaDialog(context, deteccion),
                      icon: Icon(Icons.add, size: 16),
                      label: Text('Asignar Ruta',style: TextStyle(fontSize: 10),),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📍 Información del itinerario
  Widget _buildItinerarioInfo(ItinerarioInfo itinerario) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.map, color: Colors.blue[700], size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  itinerario.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildInfoRow('Código:', itinerario.codigo),
          _buildInfoRow('Tipo:', itinerario.tipoItinerario),
          if (itinerario.distanciaTotal != null)
            _buildInfoRow('Distancia:', '${itinerario.distanciaTotal!.toStringAsFixed(1)} km'),
          if (itinerario.diasOperacion.isNotEmpty)
            _buildInfoRow('Días:', itinerario.diasOperacion.join(', ')),
        ],
      ),
    );
  }

  /// 🗺️ Información de la ruta
  Widget _buildRutaInfo(RutaInfo ruta) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route, color: Colors.green[700], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  ruta.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          if (ruta.codigo != null) _buildInfoRow('Código:', ruta.codigo!),
          if (ruta.origen != null && ruta.destino != null)
            _buildInfoRow('Trayecto:', '${ruta.origen} → ${ruta.destino}'),
          if (ruta.distanciaKm != null)
            _buildInfoRow('Distancia:', '${ruta.distanciaKm!.toStringAsFixed(1)} km'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 10, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔄 Dialog para cambiar itinerario
  void _showCambiarItinerarioDialog(BuildContext context, ItinerarioDetectado deteccion) {
    showDialog(
      context: context,
      builder: (context) => SeleccionarItinerarioDialog(
        deteccionActual: deteccion,
        onItinerarioSelected: (itinerarioId, motivo) {
          if (onSelectionChanged != null) {
            onSelectionChanged!(
              itinerarioId,
              null, // rutaId = null
              'MANUAL',
              motivo,
              deteccion.itinerario?.id, // Guardar el itinerario original
            );
          }
        },
      ),
    );
  }

  /// 🗺️ Dialog para usar ruta
  void _showUsarRutaDialog(BuildContext context, ItinerarioDetectado deteccion) {
    showDialog(
      context: context,
      builder: (context) => SeleccionarRutaDialog(
        deteccionActual: deteccion,
        onRutaSelected: (rutaId, motivo) {
          if (onSelectionChanged != null) {
            onSelectionChanged!(
              null, // itinerarioId = null
              rutaId,
              'MANUAL',
              motivo,
              deteccion.itinerario?.id, // Guardar el itinerario original detectado
            );
          }
        },
      ),
    );
  }

  /// ➕ Dialog para seleccionar itinerario manualmente
  void _showSeleccionarItinerarioDialog(BuildContext context, ItinerarioDetectado deteccion) {
    showDialog(
      context: context,
      builder: (context) => SeleccionarItinerarioDialog(
        deteccionActual: deteccion,
        onItinerarioSelected: (itinerarioId, motivo) {
          if (onSelectionChanged != null) {
            onSelectionChanged!(
              itinerarioId,
              null,
              'MANUAL',
              motivo.isNotEmpty ? motivo : null,
              null, // No hay itinerario original
            );
          }
        },
      ),
    );
  }

  /// ➕ Dialog para seleccionar ruta manualmente
  void _showSeleccionarRutaDialog(BuildContext context, ItinerarioDetectado deteccion) {
    showDialog(
      context: context,
      builder: (context) => SeleccionarRutaDialog(
        deteccionActual: deteccion,
        onRutaSelected: (rutaId, motivo) {
          if (onSelectionChanged != null) {
            onSelectionChanged!(
              null,
              rutaId,
              'MANUAL',
              motivo,
              null, // No hay itinerario original
            );
          }
        },
      ),
    );
  }
}
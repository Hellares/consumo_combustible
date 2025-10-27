// lib/presentation/page/ticket_abastecimiento/widgets/seleccionar_itinerario_dialog.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_bloc.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_event.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeleccionarItinerarioDialog extends StatefulWidget {
  final ItinerarioDetectado? deteccionActual;
  final Function(int itinerarioId, String motivo)? onItinerarioSelected;

  const SeleccionarItinerarioDialog({
    super.key,
    this.deteccionActual,
    this.onItinerarioSelected,
  });

  @override
  State<SeleccionarItinerarioDialog> createState() =>
      _SeleccionarItinerarioDialogState();
}

class _SeleccionarItinerarioDialogState
    extends State<SeleccionarItinerarioDialog> {
  Itinerario? _itinerarioSeleccionado;
  final TextEditingController _motivoController = TextEditingController();
  String? _errorMotivo;

  @override
  void initState() {
    super.initState();
    // Cargar itinerarios al abrir el diálogo
    context.read<ItinerarioBloc>().add(const LoadItinerariosActivos());
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 630),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.blue3,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.map, color: Colors.white, size: 16),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Seleccionar Itinerario',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white,size: 16,),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Detección actual (si existe)
            if (widget.deteccionActual != null &&
                widget.deteccionActual!.tieneItinerario) ...[
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.blue2),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20,),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Itinerario actual',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // const SizedBox(height: 4),
                          Text(
                            widget.deteccionActual!.itinerario!.nombre,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.blue3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Lista de itinerarios
            Expanded(
              child: BlocBuilder<ItinerarioBloc, ItinerarioState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar itinerarios',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.errorMessage ?? 'Error desconocido',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context
                                    .read<ItinerarioBloc>()
                                    .add(const LoadItinerariosActivos());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!state.hasItinerarios) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No hay itinerarios disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.itinerarios.length,
                    itemBuilder: (context, index) {
                      final itinerario = state.itinerarios[index];
                      final isSelected = _itinerarioSeleccionado?.id == itinerario.id;
                      final isActual = widget.deteccionActual?.itinerario?.id == itinerario.id;

                      return _buildItinerarioCard(
                        itinerario,
                        isSelected,
                        isActual,
                      );
                    },
                  );
                },
              ),
            ),

            // Campo de motivo
            if (_itinerarioSeleccionado != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, size: 18, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Motivo del cambio',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      borderColor: AppColors.greyLight,
                      controller: _motivoController,
                      maxLines: 2,
                      height: 50,
                      maxLength: 200,
                      hintText: 'Ej: Cambio por emergencia, apoyo en otra zona, etc.',
                      onChanged: (value) {
                        if (_errorMotivo != null) {
                          setState(() => _errorMotivo = null);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        // padding: const EdgeInsets.symmetric(vertical: 1),
                        visualDensity: VisualDensity.compact
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 11),),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _itinerarioSeleccionado != null
                          ? _confirmarSeleccion
                          : null,
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: AppColors.blue3,
                        foregroundColor: Colors.white,
                        // padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirmar', style: TextStyle(fontSize: 11),),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItinerarioCard(
  Itinerario itinerario,
  bool isSelected,
  bool isActual,
) {
  return Card(
    color: AppColors.white,
    margin: const EdgeInsets.only(bottom: 12),
    elevation: isSelected ? 3 : 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: isSelected
            ? AppColors.blue2
            : (isActual ? Colors.blue[300]! : AppColors.white),
        width: isSelected ? 1 : 0.8,
      ),
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          _itinerarioSeleccionado = itinerario;
          _errorMotivo = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 5,),
          Row(
            children: [
              // Checkbox simple en lugar de Radio
              Transform.scale(
                scale: 0.7,
                child: Checkbox(
                  visualDensity: VisualDensity.compact,
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      setState(() {
                        _itinerarioSeleccionado = itinerario;
                        _errorMotivo = null;
                      });
                    }
                  },
                ),
              ),
              // const SizedBox(width: 8),
      
              // Icono
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.map, color: Colors.blue[700], size: 18),
              ),
              const SizedBox(width: 12),
      
              // Nombre y código
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itinerario.nombre,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itinerario.codigo,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
      
              // Badge "Actual"
              if (isActual)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ACTUAL',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                ),
                
            ],
          ),
      
          // Información adicional
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.straighten,
            '${itinerario.distanciaTotal.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.loop,
            itinerario.tipoItinerario,
          ),
          const SizedBox(height: 6),
          _buildInfoRow(
            Icons.calendar_today,
            itinerario.diasOperacion.join(', '),
          ),
      
          // Tramos (si existen)
          if (itinerario.tramos != null && itinerario.tramos!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.route, size: 14, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${itinerario.tramos!.length} tramos',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        SizedBox(width: 12),
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _confirmarSeleccion() {
    if (_itinerarioSeleccionado == null) return;

    // Validar motivo si está cambiando de itinerario
    final esCambio = widget.deteccionActual?.itinerario?.id != _itinerarioSeleccionado!.id;

    if (esCambio && _motivoController.text.trim().isEmpty) {
      setState(() {
        _errorMotivo = 'Debe ingresar un motivo para el cambio';
      });
      return;
    }

    if (widget.onItinerarioSelected != null) {
      widget.onItinerarioSelected!(
        _itinerarioSeleccionado!.id,
        _motivoController.text.trim(),
      );
    }

    Navigator.pop(context);
  }
}
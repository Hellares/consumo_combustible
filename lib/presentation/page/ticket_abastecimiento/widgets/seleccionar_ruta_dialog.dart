// lib/presentation/page/ticket_abastecimiento/widgets/seleccionar_ruta_dialog.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_bloc.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_event.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SeleccionarRutaDialog extends StatefulWidget {
  final ItinerarioDetectado? deteccionActual;
  final Function(int rutaId, String motivo)? onRutaSelected;

  const SeleccionarRutaDialog({
    super.key,
    this.deteccionActual,
    this.onRutaSelected,
  });

  @override
  State<SeleccionarRutaDialog> createState() => _SeleccionarRutaDialogState();
}

class _SeleccionarRutaDialogState extends State<SeleccionarRutaDialog> {
  Ruta? _rutaSeleccionada;
  final TextEditingController _motivoController = TextEditingController();
  String? _errorMotivo;

  @override
  void initState() {
    super.initState();
    // Cargar rutas al abrir el diálogo
    context.read<RutaBloc>().add(const LoadRutasActivas());
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
                color: Colors.green[700],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.route, color: Colors.white, size: 16),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Seleccionar Ruta',
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

            // Info: Rutas son para viajes excepcionales
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[900], size: 20,),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Las rutas son para viajes excepcionales o puntuales',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de rutas
            Expanded(
              child: BlocBuilder<RutaBloc, RutaState>(
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
                              'Error al cargar rutas',
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
                                    .read<RutaBloc>()
                                    .add(const LoadRutasActivas());
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!state.hasRutas) {
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
                              'No hay rutas disponibles',
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
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: state.rutas.length,
                    itemBuilder: (context, index) {
                      final ruta = state.rutas[index];
                      final isSelected = _rutaSeleccionada?.id == ruta.id;

                      return _buildRutaCard(ruta, isSelected);
                    },
                  );
                },
              ),
            ),

            // Campo de motivo
            if (_rutaSeleccionada != null) ...[
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
                          'Motivo del viaje',
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
                      hintText: 'Ej: Viaje urgente, traslado especial, etc.',
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
                        visualDensity: VisualDensity.compact
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 11),),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _rutaSeleccionada != null ? _confirmarSeleccion : null,
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
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

  Widget _buildRutaCard(Ruta ruta, bool isSelected) {
  return Card(
    color: AppColors.white,
    margin: const EdgeInsets.only(bottom: 12),
    elevation: isSelected ? 2 : 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: BorderSide(
        color: isSelected ? Colors.green : AppColors.greyLight,
        width: isSelected ? 1 : 0.8,
      ),
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          _rutaSeleccionada = ruta;
          _errorMotivo = null;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2,),
          Row(
            children: [
              // Checkbox simple en lugar de Radio
              Transform.scale(
                scale: 0.7,
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    if (value == true) {
                      setState(() {
                        _rutaSeleccionada = ruta;
                        _errorMotivo = null;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
      
              // Icono
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.route, color: Colors.green[700], size: 16),
              ),
              const SizedBox(width: 12),
      
              // Nombre y código
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ruta.nombre,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ruta.codigo,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      
          // Trayecto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ruta.trayecto,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          // Información adicional
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(width: 12),
              _buildInfoChip(
                Icons.straighten,
                ruta.distanciaFormateada,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.access_time,
                ruta.tiempoFormateado,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 9, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  void _confirmarSeleccion() {
    if (_rutaSeleccionada == null) return;

    // Siempre requiere motivo para rutas excepcionales
    if (_motivoController.text.trim().isEmpty) {
      setState(() {
        _errorMotivo = 'Debe ingresar un motivo para usar esta ruta';
      });
      return;
    }

    if (widget.onRutaSelected != null) {
      widget.onRutaSelected!(
        _rutaSeleccionada!.id,
        _motivoController.text.trim(),
      );
    }

    Navigator.pop(context);
  }
}
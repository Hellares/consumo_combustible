import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:flutter/material.dart';

class RechazarTicketDialog extends StatefulWidget {
  final TicketAbastecimiento ticket;

  const RechazarTicketDialog({
    super.key,
    required this.ticket,
  });

  @override
  State<RechazarTicketDialog> createState() => _RechazarTicketDialogState();
}

class _RechazarTicketDialogState extends State<RechazarTicketDialog> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  String? _selectedMotivo;

  final List<String> _motivosComunes = [
    'Datos incorrectos',
    'Kilometraje inconsistente',
    'Cantidad excede capacidad',
    'Precinto inválido',
    'Grifo no autorizado',
    'Otro (especificar)',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      title: Row(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.red.shade700),
          const SizedBox(width: 12),
          const Text('Rechazar Ticket',style: TextStyle(fontSize: 12),),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info del ticket
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'Ticket: ${widget.ticket.numeroTicket}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unidad:      ${widget.ticket.unidad.placa}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    Text(
                      'Cantidad:   ${widget.ticket.cantidad} gal',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Motivos comunes
              const Text(
                'Motivo del rechazo:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _selectedMotivo,
                decoration: const InputDecoration(
                  isDense: true,
                  labelText: 'Selecciona un motivo',
                  labelStyle: TextStyle(fontSize: 12),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.list),
                ),
                items: _motivosComunes.map((motivo) {
                  return DropdownMenuItem(
                    value: motivo,
                    child: Text(motivo, style: TextStyle(fontSize: 10),),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMotivo = value;
                    if (value != 'Otro (especificar)') {
                      _motivoController.text = value ?? '';
                    } else {
                      _motivoController.clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null) return 'Selecciona un motivo';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo de texto adicional
              if (_selectedMotivo == 'Otro (especificar)') ...[
                TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Especifica el motivo *',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.edit_note),
                    isDense: true
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedMotivo == 'Otro (especificar)' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Especifica el motivo del rechazo';
                    }
                    return null;
                  },
                ),
              ] else if (_selectedMotivo != null) ...[
                TextFormField(
                  controller: _motivoController,
                  decoration: const InputDecoration(
                    labelText: 'Detalles adicionales (opcional)',
                    labelStyle: TextStyle(fontSize: 12),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                    isDense: true
                  ),
                  maxLines: 2,
                  style: TextStyle(fontSize: 12),
                ),
              ],

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(6),
                
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta acción no se puede deshacer',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            minimumSize: const Size(80, 36),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: AppLabelText('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _rechazar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 36),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: AppLabelText('Rechazar', color: AppColors.white,),
        ),
      ],
    );
  }

  void _rechazar() {
    if (!_formKey.currentState!.validate()) return;

    final motivo = _motivoController.text.trim();
    Navigator.pop(context, motivo.isNotEmpty ? motivo : _selectedMotivo);
  }
}
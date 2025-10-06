import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_event.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';


class DetalleDetailPage extends StatefulWidget {
  final DetalleAbastecimiento detalle;

  const DetalleDetailPage({
    super.key,
    required this.detalle,
  });

  @override
  State<DetalleDetailPage> createState() => _DetalleDetailPageState();
}

class _DetalleDetailPageState extends State<DetalleDetailPage> {
  late final DetalleAbastecimientoBloc _bloc;
  final _formKey = GlobalKey<FormState>();
  int? _currentUserId;

  late TextEditingController _cantidadAbastecidaController;
  late TextEditingController _motivoDiferenciaController;
  late TextEditingController _horometroActualController;
  late TextEditingController _horometroAnteriorController;
  late TextEditingController _precintoAnteriorController;
  late TextEditingController _precinto2Controller;
  late TextEditingController _costoPorUnidadController;
  late TextEditingController _costoTotalController;
  late TextEditingController _numeroTicketGrifoController;
  late TextEditingController _valeDieselController;
  late TextEditingController _numeroFacturaController;
  late TextEditingController _importeFacturaController;
  late TextEditingController _requerimientoController;
  late TextEditingController _numeroSalidaAlmacenController;
  late TextEditingController _observacionesController;
  String _unidadMedida = 'GALONES';

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<DetalleAbastecimientoBloc>();
    _loadUserSession();
    _initializeControllers();
  }

  Future<void> _loadUserSession() async {
    final authUseCases = locator<AuthUseCases>();
    final session = await authUseCases.getUserSession.run();
    if (session?.data?.user != null) {
      setState(() => _currentUserId = session!.data!.user.id);
    }
  }

  void _initializeControllers() {
    _cantidadAbastecidaController = TextEditingController(
      text: widget.detalle.cantidadAbastecida?.toString() ?? '',
    );
    _motivoDiferenciaController = TextEditingController(
      text: widget.detalle.motivoDiferencia ?? '',
    );
    _horometroActualController = TextEditingController(
      text: widget.detalle.horometroActual?.toString() ?? '',
    );
    _horometroAnteriorController = TextEditingController(
      text: widget.detalle.horometroAnterior?.toString() ?? '',
    );
    _precintoAnteriorController = TextEditingController(
      text: widget.detalle.precintoAnterior ?? '',
    );
    _precinto2Controller = TextEditingController(
      text: widget.detalle.precinto2 ?? '',
    );
    _costoPorUnidadController = TextEditingController(
      text: widget.detalle.costoPorUnidad,
    );
    _costoTotalController = TextEditingController(
      text: widget.detalle.costoTotal,
    );
    _numeroTicketGrifoController = TextEditingController(
      text: widget.detalle.numeroTicketGrifo ?? '',
    );
    _valeDieselController = TextEditingController(
      text: widget.detalle.valeDiesel ?? '',
    );
    _numeroFacturaController = TextEditingController(
      text: widget.detalle.numeroFactura ?? '',
    );
    _importeFacturaController = TextEditingController(
      text: widget.detalle.importeFactura ?? '',
    );
    _requerimientoController = TextEditingController(
      text: widget.detalle.requerimiento ?? '',
    );
    _numeroSalidaAlmacenController = TextEditingController(
      text: widget.detalle.numeroSalidaAlmacen ?? '',
    );
    _observacionesController = TextEditingController(
      text: widget.detalle.observacionesControlador ?? '',
    );
    _unidadMedida = widget.detalle.unidadMedida;
  }

  @override
  void dispose() {
    _cantidadAbastecidaController.dispose();
    _motivoDiferenciaController.dispose();
    _horometroActualController.dispose();
    _horometroAnteriorController.dispose();
    _precintoAnteriorController.dispose();
    _precinto2Controller.dispose();
    _costoPorUnidadController.dispose();
    _costoTotalController.dispose();
    _numeroTicketGrifoController.dispose();
    _valeDieselController.dispose();
    _numeroFacturaController.dispose();
    _importeFacturaController.dispose();
    _requerimientoController.dispose();
    _numeroSalidaAlmacenController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (widget.detalle.estado == 'CONCLUIDO') {
      SnackBarHelper.showWarning(context, 'No se puede editar un detalle concluido');
      return;
    }
    setState(() => _isEditing = !_isEditing);
  }

  void _guardarCambios() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'No se pudo obtener el usuario actual');
      return;
    }

    final data = <String, dynamic>{};

    // Incluir el ID del controlador (usuario actual)
    data['controladorId'] = _currentUserId;

    if (_cantidadAbastecidaController.text.isNotEmpty) {
      data['cantidadAbastecida'] = double.parse(_cantidadAbastecidaController.text);
    }
    if (_motivoDiferenciaController.text.isNotEmpty) {
      data['motivoDiferencia'] = _motivoDiferenciaController.text;
    }
    if (_horometroActualController.text.isNotEmpty) {
      data['horometroActual'] = double.parse(_horometroActualController.text);
    }
    if (_horometroAnteriorController.text.isNotEmpty) {
      data['horometroAnterior'] = double.parse(_horometroAnteriorController.text);
    }
    if (_precintoAnteriorController.text.isNotEmpty) {
      data['precintoAnterior'] = _precintoAnteriorController.text;
    }
    if (_precinto2Controller.text.isNotEmpty) {
      data['precinto2'] = _precinto2Controller.text;
    }
    data['unidadMedida'] = _unidadMedida;
    data['costoPorUnidad'] = _costoPorUnidadController.text;
    data['costoTotal'] = _costoTotalController.text;
    
    if (_numeroTicketGrifoController.text.isNotEmpty) {
      data['numeroTicketGrifo'] = _numeroTicketGrifoController.text;
    }
    if (_valeDieselController.text.isNotEmpty) {
      data['valeDiesel'] = _valeDieselController.text;
    }
    if (_numeroFacturaController.text.isNotEmpty) {
      data['numeroFactura'] = _numeroFacturaController.text;
    }
    if (_importeFacturaController.text.isNotEmpty) {
      data['importeFactura'] = _importeFacturaController.text;
    }
    if (_requerimientoController.text.isNotEmpty) {
      data['requerimiento'] = _requerimientoController.text;
    }
    if (_numeroSalidaAlmacenController.text.isNotEmpty) {
      data['numeroSalidaAlmacen'] = _numeroSalidaAlmacenController.text;
    }
    if (_observacionesController.text.isNotEmpty) {
      data['observacionesControlador'] = _observacionesController.text;
    }

    _bloc.add(ActualizarDetalleEvent(
      detalleId: widget.detalle.id,
      data: data,
    ));

    setState(() => _isEditing = false);
  }

  void _concluirDetalle() {
    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'No se pudo obtener el usuario actual');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Concluir Detalle'),
        content: const Text('¿Está seguro que desea concluir este detalle de abastecimiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.add(ConcluirDetalleEvent(
                detalleId: widget.detalle.id,
                concluidoPorId: _currentUserId!,
              ));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Concluir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.detalle.ticket.numeroTicket),
        actions: [
          if (widget.detalle.estado != 'CONCLUIDO')
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: _toggleEdit,
            ),
        ],
      ),
      body: BlocConsumer<DetalleAbastecimientoBloc, DetalleAbastecimientoState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state.actualizarResponse is Success) {
            SnackBarHelper.showSuccess(context, 'Detalle actualizado exitosamente');
            Navigator.pop(context);
          } else if (state.actualizarResponse is Error) {
            final error = state.actualizarResponse as Error;
            SnackBarHelper.showError(context, error.message);
          }

          if (state.concluirResponse is Success) {
            SnackBarHelper.showSuccess(context, 'Detalle concluido exitosamente');
            Navigator.pop(context);
          } else if (state.concluirResponse is Error) {
            final error = state.concluirResponse as Error;
            SnackBarHelper.showError(context, error.message);
          }
        },
        builder: (context, state) {
          final isLoading = state.actualizarResponse is Loading || 
                           state.concluirResponse is Loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEstadoCard(),
                  const SizedBox(height: 16),
                  _buildTicketInfoCard(),
                  const SizedBox(height: 16),
                  _buildMedicionesCard(),
                  const SizedBox(height: 16),
                  _buildCostosCard(),
                  const SizedBox(height: 16),
                  _buildDocumentosCard(),
                  const SizedBox(height: 16),
                  _buildObservacionesCard(),
                  const SizedBox(height: 24),
                  if (_isEditing) _buildActionButtons(isLoading),
                  if (!_isEditing && widget.detalle.estado == 'EN_PROGRESO')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _concluirDetalle,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Concluir Detalle'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estado:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.detalle.estadoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: widget.detalle.estadoColor),
              ),
              child: Text(
                widget.detalle.estadoTexto,
                style: TextStyle(
                  color: widget.detalle.estadoColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfoCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Ticket',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildReadOnlyField('Número de Ticket', widget.detalle.ticket.numeroTicket),
            _buildReadOnlyField('Placa', widget.detalle.ticket.placaUnidad),
            _buildReadOnlyField('Unidad', widget.detalle.ticket.unidadDescripcion),
            _buildReadOnlyField('Conductor', widget.detalle.ticket.conductorNombre),
            _buildReadOnlyField('Grifo', widget.detalle.ticket.grifoNombre),
            _buildReadOnlyField('Fecha', dateFormat.format(widget.detalle.ticket.fecha)),
            _buildReadOnlyField('Hora', timeFormat.format(widget.detalle.ticket.hora)),
            _buildReadOnlyField(
              'Cantidad Solicitada',
              '${widget.detalle.ticket.cantidad.toStringAsFixed(2)} ${widget.detalle.unidadMedida}'
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicionesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mediciones y Abastecimiento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextFormField(
              controller: _cantidadAbastecidaController,
              decoration: InputDecoration(
                labelText: 'Cantidad Abastecida (${widget.detalle.unidadMedida})',
                hintText: 'Ingrese la cantidad real abastecida',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: _isEditing,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final cantidad = double.tryParse(value);
                  if (cantidad == null) {
                    return 'Ingrese un número válido';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _motivoDiferenciaController,
              decoration: const InputDecoration(
                labelText: 'Motivo de Diferencia',
                hintText: 'Si hay diferencia, explique el motivo',
              ),
              maxLines: 2,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            TextFormField(
              controller: _horometroActualController,
              decoration: const InputDecoration(labelText: 'Horómetro Actual'),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _horometroAnteriorController,
              decoration: const InputDecoration(labelText: 'Horómetro Anterior'),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precintoAnteriorController,
              decoration: const InputDecoration(labelText: 'Precinto Anterior'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precinto2Controller,
              decoration: const InputDecoration(labelText: 'Precinto 2'),
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Costos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            DropdownButtonFormField<String>(
              value: _unidadMedida,
              decoration: const InputDecoration(labelText: 'Unidad de Medida'),
              items: const [
                DropdownMenuItem(value: 'GALONES', child: Text('GALONES')),
                DropdownMenuItem(value: 'LITROS', child: Text('LITROS')),
              ],
              onChanged: _isEditing ? (value) {
                setState(() => _unidadMedida = value!);
              } : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costoPorUnidadController,
              decoration: const InputDecoration(labelText: 'Costo por Unidad'),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _costoTotalController,
              decoration: const InputDecoration(labelText: 'Costo Total'),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentosCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documentos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextFormField(
              controller: _numeroTicketGrifoController,
              decoration: const InputDecoration(labelText: 'Número Ticket Grifo'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _valeDieselController,
              decoration: const InputDecoration(labelText: 'Vale Diesel'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numeroFacturaController,
              decoration: const InputDecoration(labelText: 'Número de Factura'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _importeFacturaController,
              decoration: const InputDecoration(labelText: 'Importe de Factura'),
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _requerimientoController,
              decoration: const InputDecoration(labelText: 'Requerimiento'),
              enabled: _isEditing,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _numeroSalidaAlmacenController,
              decoration: const InputDecoration(labelText: 'Número Salida Almacén'),
              enabled: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObservacionesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Observaciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones del Controlador',
                hintText: 'Ingrese observaciones...',
              ),
              maxLines: 3,
              enabled: _isEditing,
            ),
            if (widget.detalle.aprobadoPor != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aprobado por:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          widget.detalle.aprobadoPor!.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.detalle.fechaAprobacion != null)
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(
                              widget.detalle.fechaAprobacion!,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            if (widget.detalle.estado == 'CONCLUIDO' && 
                widget.detalle.fechaConcluido != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Concluido el:',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                            widget.detalle.fechaConcluido!,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isLoading ? null : () {
              setState(() => _isEditing = false);
              _initializeControllers(); // Restaurar valores originales
            },
            child: const Text('Cancelar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : _guardarCambios,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Guardar'),
          ),
        ),
      ],
    );
  }
}
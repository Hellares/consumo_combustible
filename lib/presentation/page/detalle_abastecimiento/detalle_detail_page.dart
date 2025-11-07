import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/models/tipo_visualizacion_ruta.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_event.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_state.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/widgets/ruta_info_card.dart';
import 'package:consumo_combustible/presentation/page/ruta_map/ruta_map_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DetalleDetailPage extends StatefulWidget {
  final DetalleAbastecimiento detalle;

  const DetalleDetailPage({super.key, required this.detalle});

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
      setState(() => _currentUserId = session!.data!.user!.id);
    }
  }

  void _initializeControllers() {
    _cantidadAbastecidaController = TextEditingController(
      text:
          (widget.detalle.cantidadAbastecida == null ||
              widget.detalle.cantidadAbastecida == 0)
          ? widget.detalle.ticket.cantidad.toString()
          : widget.detalle.cantidadAbastecida.toString(),
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

    _cantidadAbastecidaController.addListener(_updateTotalCost);
    _costoPorUnidadController.addListener(_updateTotalCost);
  }

  void _updateTotalCost() {
    final qtyText = _cantidadAbastecidaController.text;
    final unitText = _costoPorUnidadController.text;

    // Si algún campo está vacío, no calcular
    if (qtyText.isEmpty || unitText.isEmpty) {
      _costoTotalController.text = '';
      return;
    }

    // Parsear valores
    final qty = double.tryParse(qtyText);
    final unit = double.tryParse(unitText);

    // Si no se pueden parsear, no calcular
    if (qty == null || unit == null) {
      _costoTotalController.text = '';
      return;
    }

    // Calcular y formatear total (2 decimales)
    final total = qty * unit;
    _costoTotalController.text = total.toStringAsFixed(2);
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
    _cantidadAbastecidaController.removeListener(_updateTotalCost);
    _costoPorUnidadController.removeListener(_updateTotalCost);
    super.dispose();
  }

  void _toggleEdit() {
    if (widget.detalle.estado == 'CONCLUIDO') {
      SnackBarHelper.showWarning(
        context,
        'No se puede editar un detalle concluido',
      );
      return;
    }
    setState(() => _isEditing = !_isEditing);

    if (_isEditing) {
      _updateTotalCost();
    }
  }

  void _guardarCambios() {
    if (!_formKey.currentState!.validate()) return;

    if (_currentUserId == null) {
      SnackBarHelper.showError(context, 'No se pudo obtener el usuario actual');
      return;
    }

    final data = <String, dynamic>{};
    data['controladorId'] = _currentUserId;

    if (_cantidadAbastecidaController.text.isNotEmpty) {
      data['cantidadAbastecida'] = double.parse(
        _cantidadAbastecidaController.text,
      );
    }
    if (_motivoDiferenciaController.text.isNotEmpty) {
      data['motivoDiferencia'] = _motivoDiferenciaController.text;
    }
    if (_horometroActualController.text.isNotEmpty) {
      data['horometroActual'] = double.parse(_horometroActualController.text);
    }
    if (_horometroAnteriorController.text.isNotEmpty) {
      data['horometroAnterior'] = double.parse(
        _horometroAnteriorController.text,
      );
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

    _bloc.add(ActualizarDetalleEvent(detalleId: widget.detalle.id, data: data));

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline, color: AppColors.green, size: 28),
            const SizedBox(width: 12),
            const AppSubtitle('Concluir Detalle'),
          ],
        ),
        content: const AppLabelText(
          '¿Está seguro que desea concluir este detalle de abastecimiento?',
          fontSize: 11,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppLabelText(
              'Cancelar',
              color: AppColors.grey,
              fontSize: 11,
            ),
          ),
          CustomButton(
            text: 'Concluir',
            backgroundColor: AppColors.green,
            width: 100,
            height: 35,
            fontSize: 11,
            onPressed: () {
              Navigator.pop(context);
              _bloc.add(
                ConcluirDetalleEvent(
                  detalleId: widget.detalle.id,
                  concluidoPorId: _currentUserId!,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: GradientContainer(
        // gradient: AppGradients.custom(
        //   startColor: AppColors.white,
        //   middleColor: AppColors.white,
        //   endColor: AppColors.white,
        //   stops: [0.0, 0.5, 1.0],
        // ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body:
              BlocConsumer<
                DetalleAbastecimientoBloc,
                DetalleAbastecimientoState
              >(
                bloc: _bloc,
                listener: (context, state) {
                  if (state.actualizarResponse is Success) {
                    SnackBarHelper.showSuccess(
                      context,
                      'Detalle actualizado exitosamente',
                    );
                    Navigator.pop(context);
                  } else if (state.actualizarResponse is Error) {
                    final error = state.actualizarResponse as Error;
                    SnackBarHelper.showError(context, error.message);
                  }

                  if (state.concluirResponse is Success) {
                    SnackBarHelper.showSuccess(
                      context,
                      'Detalle concluido exitosamente',
                    );
                    Navigator.pop(context);
                  } else if (state.concluirResponse is Error) {
                    final error = state.concluirResponse as Error;
                    SnackBarHelper.showError(context, error.message);
                  }
                },
                builder: (context, state) {
                  final isLoading =
                      state.actualizarResponse is Loading ||
                      state.concluirResponse is Loading;

                  return Column(
                    children: [
                      // 🎨 HEADER PERSONALIZADO
                      SafeArea(child: _buildCustomHeader()),

                      // 📋 CONTENIDO SCROLL
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 12),
                                _buildEstadoCard(),
                                const SizedBox(height: 12),
                                _buildTicketInfoCard(),
                                const SizedBox(height: 12),
                                RutaInfoCard(
                                  ticket: widget.detalle.ticket,
                                  onVerRutaPressed: _navigateToRutaMap,
                                ),
                                const SizedBox(height: 12),
                                _buildMedicionesCard(),
                                const SizedBox(height: 12),
                                _buildCostosCard(),
                                const SizedBox(height: 12),
                                _buildDocumentosCard(),
                                const SizedBox(height: 12),
                                _buildObservacionesCard(),
                                const SizedBox(height: 16),
                                if (_isEditing) _buildActionButtons(isLoading),
                                if (!_isEditing &&
                                    widget.detalle.estado == 'EN_PROGRESO')
                                  _buildConcluirButton(isLoading),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }

  void _navigateToRutaMap() {
    final ticket = widget.detalle.ticket; // ✅ Obtener ticket

    // Determinar qué tipo de visualización mostrar
    final tieneItinerario = ticket.itinerario != null;
    final tieneRuta = ticket.ruta != null;

    if (!tieneItinerario && !tieneRuta) {
      SnackBarHelper.showError(
        context,
        'Este ticket no tiene ruta o itinerario asignado',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RutaMapPage(
          ticketId: widget.detalle.ticketId,
          itinerarioId: tieneItinerario ? ticket.itinerario!.id : null,
          rutaId: tieneRuta ? ticket.ruta!.id : null,
          placaUnidad: ticket.placaUnidad,
          tipoVisualizacion: tieneItinerario
              ? TipoVisualizacionRuta.itinerario
              : TipoVisualizacionRuta.rutaSimple,
        ),
      ),
    );
  }

  // 🎨 HEADER PERSONALIZADO
  Widget _buildCustomHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 18, color: AppColors.blue3),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTitle(widget.detalle.ticket.numeroTicket, fontSize: 12),
                AppLabelText(
                  'Detalle de Abastecimiento',
                  fontSize: 8,
                  color: AppColors.blueGrey,
                ),
              ],
            ),
          ),
          if (widget.detalle.estado != 'CONCLUIDO')
            IconButton(
              icon: Icon(
                _isEditing ? Icons.close : Icons.edit,
                size: 20,
                color: _isEditing ? AppColors.red : AppColors.blue3,
              ),
              onPressed: _toggleEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  // 📊 CARD DE ESTADO
  Widget _buildEstadoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.detalle.estadoColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.detalle.estadoColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            // padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.detalle.estadoColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.detalle.estado == 'CONCLUIDO'
                  ? Icons.check_circle
                  : Icons.pending,
              color: widget.detalle.estadoColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppLabelText('Estado del Detalle', fontSize: 8),
                const SizedBox(height: 2),
                AppTitle(
                  widget.detalle.estadoTexto,
                  fontSize: 11,
                  color: widget.detalle.estadoColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🎫 INFORMACIÓN DEL TICKET
  Widget _buildTicketInfoCard() {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              Icon(Icons.receipt_long, size: 18, color: AppColors.blue3),
              const SizedBox(width: 8),
              AppSubtitle('Información del Ticket', fontSize: 11),
            ],
          ),
          const SizedBox(height: 5),
          _buildInfoRow(
            'N° Ticket',
            widget.detalle.ticket.numeroTicket,
            Icons.tag,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Placa',
            widget.detalle.ticket.placaUnidad,
            Icons.directions_car,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Unidad',
            widget.detalle.ticket.unidadDescripcion,
            Icons.build,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Conductor',
            widget.detalle.ticket.conductorNombre,
            Icons.person,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Grifo',
            widget.detalle.ticket.grifoNombre,
            Icons.local_gas_station,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Fecha',
            dateFormat.format(widget.detalle.ticket.fecha),
            Icons.calendar_today,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Hora',
            timeFormat.format(widget.detalle.ticket.hora),
            Icons.access_time,
          ),
          _buildDivider(),
          _buildInfoRow(
            'Cantidad Solicitada',
            '${widget.detalle.ticket.cantidad.toStringAsFixed(2)} ${widget.detalle.unidadMedida}',
            Icons.opacity,
          ),
        ],
      ),
    );
  }

  // 📏 MEDICIONES Y ABASTECIMIENTO
  Widget _buildMedicionesCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
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
          Row(
            children: [
              Icon(Icons.speed, size: 18, color: AppColors.blue3),
              const SizedBox(width: 8),
              AppSubtitle('Mediciones', fontSize: 11),
            ],
          ),
          const SizedBox(height: 5),
          CustomTextField(
            label: 'Cantidad Abastecida',
            controller: _cantidadAbastecidaController,
            enabled: _isEditing,
            keyboardType: TextInputType.number,
            prefixIcon: Icon(
              Icons.local_gas_station,
              color: AppColors.blue3,
              size: 16,
            ),
            borderColor: AppColors.blue3,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'Motivo de Diferencia',
            controller: _motivoDiferenciaController,
            enabled: _isEditing,
            // prefixIcon: Icons.info_outline,
            prefixIcon: Icon(
              Icons.info_outline,
              color: AppColors.blue3,
              size: 16,
            ),
            borderColor: AppColors.orange,
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Horómetro Actual',
                  controller: _horometroActualController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  // prefixIcon: Icons.speed,
                  prefixIcon: Icon(
                    Icons.speed,
                    color: AppColors.blue3,
                    size: 16,
                  ),
                  borderColor: AppColors.blue3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  label: 'Horómetro Anterior',
                  controller: _horometroAnteriorController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.number,
                  // prefixIcon: Icons.history,
                  prefixIcon: Icon(
                    Icons.history,
                    color: AppColors.blue3,
                    size: 16,
                  ),
                  borderColor: AppColors.blue3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Precinto Anterior',
                  controller: _precintoAnteriorController,
                  enabled: _isEditing,
                  // prefixIcon: Icons.lock_outline,
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: AppColors.blue3,
                    size: 16,
                  ),
                  borderColor: AppColors.blue3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  label: 'Precinto Nuevo',
                  controller: _precinto2Controller,
                  enabled: _isEditing,
                  // prefixIcon: Icons.lock,
                  borderColor: AppColors.blue3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomDropdown<String>(
            label: 'Unidad de Medida',
            value: _unidadMedida,
            items: const [
              DropdownItem(value: 'GALONES', label: 'GALONES'),
              DropdownItem(value: 'LITROS', label: 'LITROS'),
            ],
            onChanged: _isEditing
                ? (value) {
                    setState(() => _unidadMedida = value!);
                  }
                : null,
            borderColor: AppColors.blue3,
          ),
        ],
      ),
    );
  }

  // 💰 COSTOS
  Widget _buildCostosCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              AppSubtitle('Costos', fontSize: 11),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Costo por Unidad',
                  controller: _costoPorUnidadController,
                  fieldType: FieldType.currency,
                  enabled: _isEditing,
                  hintText: '0.00',
                  currencySymbol: 'S/',
                  enableRealTimeValidation: true,
                  borderColor: AppColors.green,
                  validator: (value) => FieldValidators.validateCurrency(
                    value,
                    minAmount: 0.00,
                    maxAmount: 10000.00,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Costo Total',
                  controller: _costoTotalController,
                  fieldType: FieldType.currency,
                  enabled: false,
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.calculate,
                    color: AppColors.green,
                    size: 16,
                  ),
                  enableRealTimeValidation: false,
                  borderColor: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 📄 DOCUMENTOS
  Widget _buildDocumentosCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(Icons.description, size: 18, color: AppColors.blue3),
              const SizedBox(width: 8),
              AppSubtitle('Documentos', fontSize: 11),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'N° Ticket Grifo',
            controller: _numeroTicketGrifoController,
            enabled: _isEditing,
            // prefixIcon: Icons.receipt,
            prefixIcon: Icon(Icons.receipt, color: AppColors.blue3, size: 16),
            borderColor: AppColors.blue3,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'Vale Diesel',
            controller: _valeDieselController,
            enabled: _isEditing,
            // prefixIcon: Icons.card_giftcard,
            prefixIcon: Icon(
              Icons.card_giftcard,
              color: AppColors.blue3,
              size: 16,
            ),
            borderColor: AppColors.blue3,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'N° Factura',
                  controller: _numeroFacturaController,
                  enabled: _isEditing,
                  prefixIcon: Icon(
                    Icons.description,
                    color: AppColors.blue3,
                    size: 16,
                  ),
                  // prefixIcon: Icons.description,
                  borderColor: AppColors.blue3,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  label: 'Importe Factura',
                  controller: _importeFacturaController,
                  fieldType: FieldType.currency,
                  enabled: _isEditing,
                  hintText: '0.00',
                  currencySymbol: 'S/',
                  enableRealTimeValidation: false,
                  borderColor: AppColors.blue3,
                  validator: (value) => FieldValidators.validateCurrency(
                    value,
                    minAmount: 0.00,
                    maxAmount: 1000000.00,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'Requerimiento',
            controller: _requerimientoController,
            enabled: _isEditing,
            // prefixIcon: Icons.note,
            prefixIcon: Icon(Icons.note, color: AppColors.blue3, size: 16),
            borderColor: AppColors.blue3,
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: 'N° Salida Almacén',
            controller: _numeroSalidaAlmacenController,
            enabled: _isEditing,
            prefixIcon: Icon(Icons.warehouse, color: AppColors.blue3, size: 16),
            // prefixIcon: Icons.warehouse,
            borderColor: AppColors.blue3,
          ),
        ],
      ),
    );
  }

  // 📝 OBSERVACIONES (Continuación desde donde quedó)
  Widget _buildObservacionesCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              Icon(Icons.comment, size: 18, color: AppColors.blue3),
              const SizedBox(width: 8),
              AppSubtitle('Observaciones', fontSize: 11),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Observaciones del Controlador',
            controller: _observacionesController,
            enabled: _isEditing,
            height: 80,
            maxLines: 4,
            // prefixIcon: Icons.note_alt,
            borderColor: AppColors.blue3,
          ),
        ],
      ),
    );
  }

  // 🎯 BOTONES DE ACCIÓN (CUANDO ESTÁ EDITANDO)
  Widget _buildActionButtons(bool isLoading) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Cancelar',
            gradient: AppGradients.sinfondo,
            borderColor: AppColors.grey,
            height: 42,
            fontSize: 11,
            textColor: AppColors.grey,
            onPressed: isLoading
                ? null
                : () {
                    setState(() => _isEditing = false);
                    _initializeControllers(); // Restaurar valores originales
                  },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Guardar Cambios',
            gradient: AppGradients.custom(
              startColor: AppColors.blue3,
              middleColor: AppColors.blue3,
              endColor: AppColors.blue3.withValues(alpha: 0.8),
            ),
            borderColor: AppColors.blue3,
            height: 42,
            fontSize: 11,
            onPressed: isLoading ? null : _guardarCambios,
          ),
        ),
      ],
    );
  }

  // ✅ BOTÓN CONCLUIR (CUANDO NO ESTÁ EDITANDO)
  Widget _buildConcluirButton(bool isLoading) {
    return CustomButton(
      text: 'Concluir Detalle',
      gradient: AppGradients.custom(
        startColor: AppColors.green,
        middleColor: AppColors.green,
        endColor: AppColors.green.withValues(alpha: 0.8),
      ),
      borderColor: AppColors.green,
      width: double.infinity,
      height: 42,
      fontSize: 12,
      onPressed: isLoading ? null : _concluirDetalle,
    );
  }

  // 📋 HELPER: ROW DE INFORMACIÓN
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.blueGrey),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: AppLabelText(label, fontSize: 9, color: AppColors.blueGrey),
          ),
          Expanded(
            child: AppLabelText(value, fontSize: 9, color: AppColors.blue3),
          ),
        ],
      ),
    );
  }

  // 📏 HELPER: DIVIDER
  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: AppColors.grey.withValues(alpha: 0.3),
    );
  }
}

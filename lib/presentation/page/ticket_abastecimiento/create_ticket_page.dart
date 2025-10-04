import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTicketPage extends StatefulWidget {
  const CreateTicketPage({super.key});

  @override
  State<CreateTicketPage> createState() => _CreateTicketPageState();
}

class _CreateTicketPageState extends State<CreateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  late final TicketBloc _bloc;

  // Controllers
  final _kilometrajeController = TextEditingController();
  final _precintoController = TextEditingController();
  final _cantidadController = TextEditingController();

  // Data
  SelectedLocation? _location;
  int? _selectedUnidadId;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<TicketBloc>();
    _loadData();
  }

  Future<void> _loadData() async {
    final locationUseCases = locator<LocationUseCases>();
    final location = await locationUseCases.getSelectedLocation.run();

    if (location == null) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Selecciona una ubicación primero');
        Navigator.pop(context);
      }
      return;
    }

    setState(() => _location = location);
  }

  @override
  Widget build(BuildContext context) {
    if (_location == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return GradientContainer(
      gradient: AppGradients.custom(
        startColor: AppColors.white,
        middleColor: AppColors.white,
        endColor: AppColors.white,
        stops: [0.0, 0.5, 1.0],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // appBar: AppBar(title: const Text('Crear Ticket de Abastecimiento')),
        appBar: AppBar( title: AppSubtitle('CREAR TICKET DE ABASTECIMIENTO'),backgroundColor: Colors.transparent,),
        body: BlocConsumer<TicketBloc, TicketState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state.createResponse is Success) {
              final ticket =
                  (state.createResponse as Success).data as TicketAbastecimiento;
      
              _showSuccessDialog(ticket);
            } else if (state.createResponse is Error) {
              final error = state.createResponse as Error;
              SnackBarHelper.showError(context, error.message);
            }
          },
          builder: (context, state) {
            final isLoading = state.createResponse is Loading;
      
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationCard(),
                    const SizedBox(height: 24),
                    _buildUnidadSelector(),
                    const SizedBox(height: 16),
                    _buildKilometrajeField(),
                    const SizedBox(height: 16),
                    _buildPrecintoField(),
                    const SizedBox(height: 16),
                    _buildCantidadField(),
                    const SizedBox(height: 32),
                    _buildSubmitButton(isLoading),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal:15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.red),
                const SizedBox(width: 8),
                // const Text(
                //   'Ubicación de abastecimiento',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                AppSubtitle('Ubicacion de abastecimiento'),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      'location-selection',
                    );
                    
                    // ✅ Verificar mounted antes de usar context
                    if (!mounted) return;
                    
                    // Si se guardó exitosamente, recargar ubicación
                    if (result == true) {
                      final locationUseCases = locator<LocationUseCases>();
                      final newLocation = await locationUseCases.getSelectedLocation.run();
                      
                      if (!mounted) return;
                      
                      if (newLocation != null) {
                        setState(() => _location = newLocation);
                        SnackBarHelper.showSuccess(context, 'Ubicación actualizada');
                      }
                    }
                  },
                  child: AppSubtitle('Cambiar', font: AppFont.oxygenBold,color: AppColors.orange,),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Grifo:', _location!.grifo.nombre),
            _buildInfoRow('Dirección:', _location!.grifo.direccion),
            _buildInfoRow('Sede:', _location!.sede.nombre),
            _buildInfoRow('Zona:', _location!.zona.nombre),
          ],
        ),
      ),
    );
  }

  Widget _buildUnidadSelector(){
    return CustomDropdown<int>(
      items: [
        DropdownItem(value: 1, label: 'Unidad 001'),
        DropdownItem(value: 2, label: 'Unidad 002'),
      ],
      borderColor: AppColors.blue3,
    );
  }

  Widget _buildKilometrajeField() {
    return CustomTextField(
      controller: _kilometrajeController,
      hintText: 'Kilometraje Actual *',
      borderColor: AppColors.blue3,
      prefixIcon: Icon(Icons.speed),
      suffixText: 'km',
      keyboardType: TextInputType.number,
      validator: (value){
        if (value == null || value.isEmpty) return 'Ingrese el kilometraje';
        if (double.tryParse(value) == null) return 'Número inválido';
        return null;
      },
    );
  }

  Widget _buildPrecintoField() {
    return TextFormField(
      controller: _precintoController,
      decoration: const InputDecoration(
        labelText: 'Precinto Nuevo *',
        hintText: 'PR-2024-002210',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingresa el precinto' : null,
    );
  }

  Widget _buildCantidadField() {
    return TextFormField(
      controller: _cantidadController,
      decoration: const InputDecoration(
        labelText: 'Cantidad de Combustible *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.local_gas_station),
        suffixText: 'gal',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa la cantidad';
        final cantidad = double.tryParse(value);
        if (cantidad == null) return 'Número inválido';
        if (cantidad <= 0) return 'Debe ser mayor a 0';
        return null;
      },
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _createTicket,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
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
            : const Text(
                'Crear Ticket',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: AppLabelText(label),
          ),
          Expanded(child: AppLabelText(value)),
        ],
      ),
    );
  }

  Future<void> _createTicket() async {
    if (!_formKey.currentState!.validate()) return;

    final authUseCases = locator<AuthUseCases>();
    final userSession = await authUseCases.getUserSession.run();

    // ✅ Verificar mounted después del await
    if (!mounted) return;

    if (userSession == null) {
      SnackBarHelper.showError(context, 'Sesión no válida');
      return;
    }

    final request = CreateTicketRequest(
      unidadId: _selectedUnidadId!,
      conductorId: userSession.data!.user.id,
      grifoId: _location!.grifo.id,
      kilometrajeActual: double.parse(_kilometrajeController.text),
      precintoNuevo: _precintoController.text,
      cantidad: double.parse(_cantidadController.text),
    );

    _bloc.add(CreateTicket(request));
  }

  // ✅ SOLUCIÓN: Solo cerrar diálogo, sin Navigator.pop extra
  void _showSuccessDialog(TicketAbastecimiento ticket) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(Icons.check_circle, color: Colors.green.shade600, size: 64),
        title: const Text('Ticket Creado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Número: ${ticket.numeroTicket}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSuccessInfoRow('Estado:', ticket.estado.nombre),
            _buildSuccessInfoRow('Fecha:', ticket.fecha),
            _buildSuccessInfoRow('Hora:', ticket.hora),
            _buildSuccessInfoRow('Cantidad:', '${ticket.cantidad} gal'),
            _buildSuccessInfoRow('Grifo:', ticket.grifo.nombre),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ticket.estado.colorValue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                ticket.estado.descripcion,
                style: TextStyle(fontSize: 12, color: ticket.estado.colorValue),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ✅ Solo cerrar diálogo
              _bloc.add(const ResetTicketState()); // Resetear estado
              _clearForm(); // Limpiar formulario
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // ✅ Limpiar formulario después de crear ticket
  void _clearForm() {
    _formKey.currentState?.reset();
    _kilometrajeController.clear();
    _precintoController.clear();
    _cantidadController.clear();
    setState(() => _selectedUnidadId = null);
  }

  Widget _buildSuccessInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _kilometrajeController.dispose();
    _precintoController.dispose();
    _cantidadController.dispose();
    super.dispose();
  }
}
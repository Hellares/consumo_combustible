import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
// import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_event.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/widgets/ticket_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';

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
  int? _currentZonaId; // ✅ NUEVO: Para detectar cambios de zona

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

    setState(() {
      _location = location;
      _currentZonaId = location.zona.id;
    });

    // ✅ CARGAR UNIDADES DE LA ZONA
    _bloc.add(LoadUnidadesByZona(location.zona.id));
  }

  // ✅ NUEVO: Método para recargar cuando cambia la ubicación
  Future<void> _checkAndReloadLocation() async {
  // Capturar messenger ANTES de cualquier await
  final messenger = ScaffoldMessenger.of(context);
  
  final locationUseCases = locator<LocationUseCases>();
  final newLocation = await locationUseCases.getSelectedLocation.run();

  if (newLocation == null) return;

  // Detectar si cambió la zona
  if (_currentZonaId != null && _currentZonaId != newLocation.zona.id) {
    final unidadUseCases = locator<UnidadUseCases>();
    await unidadUseCases.clearUnidadesCache.run(zonaId: _currentZonaId);

    if (!mounted) return;

    setState(() {
      _location = newLocation;
      _currentZonaId = newLocation.zona.id;
      _selectedUnidadId = null;
    });

    _bloc.add(LoadUnidadesByZona(newLocation.zona.id));
    SnackBarHelper.showInfoWithMessenger(
      messenger,
      'Ubicación actualizada: ${newLocation.zona.nombre}',
    );
  } else if (_location?.grifo.id != newLocation.grifo.id) {
    if (!mounted) return;

    setState(() => _location = newLocation);
    SnackBarHelper.showInfoWithMessenger(
      messenger,
      'Grifo actualizado: ${newLocation.grifo.nombre}',
    );
  }
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
        body: Column(
          children: [
            Container(
            height: 25,
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppTitle('CREAR TICKET DE ABASTECIMIENTO', fontSize: 10,),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.refresh, size: 20, color: Colors.blue),
                  onPressed: _refreshUnidades,
                ),
              ],
            ),
          ),
            Expanded(
              child: BlocConsumer<TicketBloc, TicketState>(
                bloc: _bloc,
                listener: (context, state) {
                  // Listener para errores de unidades
                  if (state.unidadesResponse is Error) {
                    final error = state.unidadesResponse as Error;
                    SnackBarHelper.showError(context, error.message);
                  }
              
                  // Listener para creación de ticket
                  if (state.createResponse is Success) {
                    final ticket =
                        (state.createResponse as Success).data
                            as TicketAbastecimiento;
                    _showSuccessDialog(ticket);
                  } else if (state.createResponse is Error) {
                    final error = state.createResponse as Error;
                    SnackBarHelper.showError(context, error.message);
                  }
                },
                builder: (context, state) {
                  final isLoadingTicket = state.createResponse is Loading;
              
                  return Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLocationCard(),
                          const SizedBox(height: 24),
              
                          // ✅ DROPDOWN DINÁMICO
                          _buildUnidadSelector(state),
              
                          const SizedBox(height: 16),
                          _buildKilometrajeField(),
              
                          const SizedBox(height: 16),
                          _buildPrecintoField(),
                          const SizedBox(height: 16),
                          _buildCantidadField(),
                          const SizedBox(height: 32),
                          _buildSubmitButton(isLoadingTicket),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshUnidades() async {
    final location = _location;
    if (location == null) return;

    final unidadUseCases = locator<UnidadUseCases>();

    await unidadUseCases.clearUnidadesCache.run(zonaId: location.zona.id);

    if (!mounted) return;

    _bloc.add(LoadUnidadesByZona(location.zona.id));
    SnackBarHelper.showInfo(context, 'Unidades actualizadas');
  }

  Widget _buildLocationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: AppSubtitle('UBICACION ACTUAL', fontSize: 9,),
                ),
                // ✅ BOTÓN PARA CAMBIAR UBICACIÓN
                InkWell(
                  onTap: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      'location-selection', // Tu ruta de selección de ubicación
                    );

                    // ✅ Si regresó con cambios (result == true)
                    if (result == true && mounted) {
                      await _checkAndReloadLocation(); // ← AQUÍ SE USA
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_location,
                          size: 16,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: 4),
                        AppLabelText('Cambiar',fontSize: 8,)
                      ],
                    ),
                  ),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          SizedBox(width: 100, child: AppLabelText(label)),
          Expanded(child: AppLabelText(value)),
        ],
      ),
    );
  }

  // ✅ NUEVO: Dropdown dinámico con unidades de la API
  Widget _buildUnidadSelector(TicketState state) {
    final isLoading = state.unidadesResponse is Loading;
    final hasError = state.unidadesResponse is Error;
    final unidades = state.unidades;

    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Cargando unidades...'),
            ],
          ),
        ),
      );
    }

    if (hasError) {
      final errorMessage =
          state.unidadesErrorMessage ?? 'Error al cargar unidades';
      return Card(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    _bloc.add(LoadUnidadesByZona(_location!.zona.id)),
              ),
            ],
          ),
        ),
      );
    }

    // Si no hay respuesta aún o está en estado inicial
    if (state.unidadesResponse == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Inicializando...'),
            ],
          ),
        ),
      );
    }

    if (unidades.isEmpty) {
      return Card(
        color: Colors.orange.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('No hay unidades disponibles en esta zona'),
              ),
            ],
          ),
        ),
      );
    }

    return CustomDropdown<int>(
      items: unidades.map((unidad) {
        return DropdownItem(
          value: unidad.id,
          label: '${unidad.placa} - ${unidad.marca} ${unidad.modelo}',
        );
      }).toList(),
      value: _selectedUnidadId,
      hintText: 'Selecciona una unidad *',
      borderColor: AppColors.blue3,
      prefixIcon: const Icon(Icons.local_shipping),
      onChanged: (value) {
        setState(() => _selectedUnidadId = value);
      },
      validator: (value) {
        if (value == null) return 'Selecciona una unidad';
        return null;
      },
    );
  }

  Widget _buildKilometrajeField() {
    return CustomTextField(
      controller: _kilometrajeController,
      hintText: 'Kilometraje Actual *',
      borderColor: AppColors.blue3,
      prefixIcon: const Icon(Icons.speed),
      suffixText: 'km',
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(7),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese el kilometraje';
        final km = double.tryParse(value);
        if (km == null) return 'Número inválido';
        if (km < 0) return 'No puede ser negativo';
        if (km > 9999999) return 'Valor muy alto';
        return null;
      },
    );
  }

  Widget _buildPrecintoField() {
    return CustomTextField(
      controller: _precintoController,
      hintText: 'Precinto Nuevo *',
      borderColor: AppColors.blue3,
      prefixIcon: const Icon(Icons.lock),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingresa el precinto';
        if (value.length < 5) return 'Precinto muy corto';
        return null;
      },
    );
  }

  Widget _buildCantidadField() {
  // Obtener unidad seleccionada si existe
  final unidadSeleccionada = _selectedUnidadId != null
      ? _bloc.state.unidades.firstWhereOrNull((u) => u.id == _selectedUnidadId)
      : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomTextField(
        controller: _cantidadController,
        hintText: 'Cantidad de Combustible *',
        borderColor: AppColors.blue3,
        prefixIcon: const Icon(Icons.local_gas_station),
        suffixText: 'gal',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Ingresa la cantidad';
          final cantidad = double.tryParse(value);
          if (cantidad == null) return 'Número inválido';
          if (cantidad <= 0) return 'Debe ser mayor a 0';
          if (cantidad > 1000) return 'Cantidad muy alta';
          
          if (_selectedUnidadId != null) {
            final unidad = _bloc.state.unidades.firstWhere(
              (u) => u.id == _selectedUnidadId,
            );
            
            if (cantidad > unidad.capacidadTanque) {
              return 'Excede capacidad del tanque (${unidad.capacidadTanque} gal)';
            }
          }
          
          return null;
        },
      ),
      
      // ✅ Helper text con capacidad del tanque
      if (unidadSeleccionada != null) ...[
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 4),
              Text(
                'Capacidad del tanque: ${unidadSeleccionada.capacidadTanque} gal',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

  Widget _buildSubmitButton(bool isLoading) {
    return CustomButton(
      text: 'Crear Ticket',
      width: double.infinity,
      backgroundColor: AppColors.blue,
      buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
      loadingText: 'Creando...',
      loadingIndicatorColor: AppColors.green,
      enabled: !isLoading,
      onPressed: _createTicket,
      enableShadows: true,
    );
  }

 



  Future<void> _createTicket() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedUnidadId == null) {
    SnackBarHelper.showError(context, 'Selecciona una unidad');
    return;
  }

  // Obtener la unidad seleccionada
  final unidadSeleccionada = _bloc.state.unidades.firstWhere(
    (u) => u.id == _selectedUnidadId,
  );

  // Mostrar diálogo de confirmación
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => TicketConfirmationDialog(
      unidad: unidadSeleccionada,
      location: _location!,
      kilometraje: double.parse(_kilometrajeController.text),
      precinto: _precintoController.text,
      cantidad: double.parse(_cantidadController.text),
      onConfirm: () => Navigator.of(dialogContext).pop(true),
      onCancel: () => Navigator.of(dialogContext).pop(false),
    ),
  );

  // Si no confirmó, salir
  if (confirmed != true) return;

  // Continuar con la creación del ticket
  final authUseCases = locator<AuthUseCases>();
  final userSession = await authUseCases.getUserSession.run();

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
              Navigator.pop(dialogContext);
              _bloc.add(const ResetTicketState());
              _clearForm();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _kilometrajeController.clear();
    _precintoController.clear();
    _cantidadController.clear();
    setState(() => _selectedUnidadId = null);
    if (_location != null) {
      _bloc.add(LoadUnidadesByZona(_location!.zona.id));
    }
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

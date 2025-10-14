import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_time.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_bloc.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_event.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditGrifoPage extends StatefulWidget {
  final int grifoId;

  const EditGrifoPage({
    super.key,
    required this.grifoId,
  });

  @override
  State<EditGrifoPage> createState() => _EditGrifoPageState();
}

class _EditGrifoPageState extends State<EditGrifoPage> {
  final _formKey = GlobalKey<FormState>();
  final _sedeController = TextEditingController();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _horarioAperturaController = TextEditingController();
  final _horarioCierreController = TextEditingController();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrifoBloc>().add(InitEditGrifoFormEvent(widget.grifoId));
    });
  }

  @override
  void dispose() {
    _sedeController.dispose();
    _nombreController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _horarioAperturaController.dispose();
    _horarioCierreController.dispose();
    super.dispose();
  }

  void _initializeControllers(GrifoState state) {
    if (!_isInitialized && state.grifoByIdResponse is Success) {
      final grifo = (state.grifoByIdResponse as Success).data;
      
      // Obtener el nombre de la sede directamente del grifo cargado
      _sedeController.text = grifo.sede?.nombre ?? 'Sede ID: ${grifo.sedeId}';
      _nombreController.text = state.nombre;
      _codigoController.text = state.codigo;
      _direccionController.text = state.direccion;
      _telefonoController.text = state.telefono;
      _horarioAperturaController.text = state.horarioApertura;
      _horarioCierreController.text = state.horarioCierre;
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: SmartAppBar(
        title: 'Editar Grifo',
        showUserInfo: true,
        logoPath: 'assets/img/6.svg',
        onLeftTap: () => Navigator.pop(context),
      ),
      body: BlocConsumer<GrifoBloc, GrifoState>(
        listenWhen: (previous, current) {
          // Solo escuchar cuando updateGrifoResponse cambia de null a un valor
          return previous.updateGrifoResponse != current.updateGrifoResponse &&
                 current.updateGrifoResponse != null;
        },
        listener: _blocListener,
        builder: (context, state) {
          // Inicializar controladores cuando se carga el grifo
          _initializeControllers(state);

          if (state.isLoadingGrifoById) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 5),
                  _buildSedeField(state),
                  const SizedBox(height: 12),
                  _buildNombreField(state),
                  const SizedBox(height: 16),
                  _buildCodigoField(state),
                  const SizedBox(height: 16),
                  _buildDireccionField(state),
                  const SizedBox(height: 16),
                  _buildTelefonoField(state),
                  const SizedBox(height: 16),
                  _buildHorariosRow(state),
                  const SizedBox(height: 10),
                  _buildActivoSwitch(state),
                  const SizedBox(height: 10),
                  _buildSubmitButton(state),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ========== LISTENER ==========

  void _blocListener(BuildContext context, GrifoState state) {
    if (state.updateGrifoResponse != null) {
      if (state.updateGrifoResponse is Success) {
        final grifo = (state.updateGrifoResponse as Success).data;
        _showSuccessSnackbar('Grifo "${grifo.nombre}" actualizado exitosamente');
        Navigator.pop(context, true); // Retornar true para indicar que se actualizó
      } else if (state.updateGrifoResponse is Error) {
        final errorMsg = (state.updateGrifoResponse as Error).message;
        _showErrorSnackbar(errorMsg);
      }
    }
  }

  // ========== BUILDERS ==========

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EDITAR GRIFO',
          style: AppFont.oxygenBold.style(fontSize: 10, color: AppColors.blue3),
        ),
        Text(
          'Modifique los datos del grifo',
          style: AppFont.oxygenRegular.style(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSedeField(GrifoState state) {
    return CustomTextField(
      controller: _sedeController,
      label: 'Sede',
      hintText: 'Sede del grifo',
      prefixIcon: const Icon(Icons.business_outlined),
      borderColor: AppColors.blue3,
      enabled: false, // Campo de solo lectura
      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildNombreField(GrifoState state) {
    return CustomTextField(
      controller: _nombreController,
      label: 'Nombre',
      hintText: 'Nombre del grifo',
      prefixIcon: const Icon(Icons.local_gas_station_outlined),
      borderColor: AppColors.blue3,
      enabled: false, // Campo de solo lectura
      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildCodigoField(GrifoState state) {
    return CustomTextField(
      controller: _codigoController,
      label: 'Código',
      hintText: 'Código del grifo',
      textCase: TextCase.upper,
      prefixIcon: const Icon(Icons.code_rounded),
      borderColor: AppColors.blue3,
      enabled: false, // Campo de solo lectura
      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildDireccionField(GrifoState state) {
    return CustomTextField(
      label: 'Dirección',
      hintText: 'Dirección del grifo',
      controller: _direccionController,
      prefixIcon: const Icon(Icons.location_on_outlined),
      borderColor: AppColors.blue3,
      enabled: false, // Campo de solo lectura
      backgroundColor: AppColors.grey.withValues(alpha: 0.1),
    );
  }

  Widget _buildTelefonoField(GrifoState state) {
    return CustomTextField(
      label: 'Teléfono',
      hintText: 'Teléfono de contacto',
      controller: _telefonoController,
      prefixIcon: const Icon(Icons.phone_outlined),
      borderColor: AppColors.blue3,
      enableRealTimeValidation: false,
      onChanged: (value) {
        context.read<GrifoBloc>().add(GrifoTelefonoChangedEvent(value));
      },
    );
  }

  Widget _buildHorariosRow(GrifoState state) {
    return Row(
      children: [
        Expanded(
          child: _buildTimeField(
            label: 'Apertura',
            controller: _horarioAperturaController,
            onTimeSelected: (hour, minute) {
              final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              _horarioAperturaController.text = timeString;
              context.read<GrifoBloc>().add(GrifoHorarioAperturaChangedEvent(timeString));
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeField(
            label: 'Cierre',
            controller: _horarioCierreController,
            onTimeSelected: (hour, minute) {
              final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              _horarioCierreController.text = timeString;
              context.read<GrifoBloc>().add(GrifoHorarioCierreChangedEvent(timeString));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required void Function(int hour, int minute) onTimeSelected,
  }) {
    return GestureDetector(
      onTap: () async {
        // Parsear la hora actual del controller
        int initialHour = 0;
        int initialMinute = 0;
        
        if (controller.text.isNotEmpty) {
          final parts = controller.text.split(':');
          if (parts.length == 2) {
            initialHour = int.tryParse(parts[0]) ?? 0;
            initialMinute = int.tryParse(parts[1]) ?? 0;
          }
        }

        await showDialog(
          context: context,
          builder: (context) => TimeScrollPicker(
            initialHour: initialHour,
            initialMinute: initialMinute,
            primaryColor: AppColors.blue3,
            onTimeSelected: onTimeSelected,
          ),
        );
      },
      child: AbsorbPointer(
        child: CustomTextField(
          label: label,
          hintText: '00:00',
          controller: controller,
          prefixIcon: const Icon(Icons.access_time, size: 18),
          suffixIcon: const Icon(Icons.arrow_drop_down, size: 20),
          borderColor: AppColors.blue3,
          enableRealTimeValidation: false,
        ),
      ),
    );
  }

  Widget _buildActivoSwitch(GrifoState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Estado',
          style: AppFont.pirulentBold.style(
            fontSize: 8,
            color: AppColors.blue3,
          ),
        ),
        Row(
          children: [
            Text(
              state.activo ? 'Activo' : 'Inactivo',
              style: AppFont.pirulentBold.style(
                fontSize: 8,
                color: state.activo ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: state.activo,
                activeThumbColor: AppColors.green,
                onChanged: (value) {
                  context.read<GrifoBloc>().add(GrifoActivoChangedEvent(value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(GrifoState state) {
    // En modo edición, solo validamos que haya datos cargados
    final canSubmit = !state.isLoading &&
                      !state.isLoadingGrifoById &&
                      state.selectedSedeId != null;
    
    return CustomButton(
      text: 'Actualizar Grifo',
      onPressed: canSubmit ? () => _submitForm(state) : null,
      enabled: canSubmit,
      buttonState: state.isLoading ? ButtonState.loading : ButtonState.idle,
      backgroundColor: canSubmit ? AppColors.blue3 : AppColors.grey,
      textColor: AppColors.white,
      height: 35,
      borderRadius: 16,
    );
  }

  // ========== HELPERS ==========

  void _submitForm(GrifoState state) {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateGrifoRequest(
        sedeId: state.selectedSedeId!,
        nombre: state.nombre.trim(),
        codigo: state.codigo.trim().toUpperCase(),
        direccion: state.direccion.trim().isNotEmpty 
            ? state.direccion.trim() 
            : null,
        telefono: state.telefono.trim().isNotEmpty 
            ? state.telefono.trim() 
            : null,
        horarioApertura: state.horarioApertura.trim().isNotEmpty
            ? state.horarioApertura.trim()
            : null,
        horarioCierre: state.horarioCierre.trim().isNotEmpty
            ? state.horarioCierre.trim()
            : null,
        activo: state.activo,
      );

      context.read<GrifoBloc>().add(UpdateGrifoEvent(widget.grifoId, request));
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_time.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/custom_dropdown2.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/dropdown_adapters.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_bloc.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_event.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGrifoPage extends StatefulWidget {
  const CreateGrifoPage({super.key});

  @override
  State<CreateGrifoPage> createState() => _CreateGrifoPageState();
}

class _CreateGrifoPageState extends State<CreateGrifoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _horarioAperturaController = TextEditingController();
  final _horarioCierreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrifoBloc>().add(const InitGrifoFormEvent());
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _horarioAperturaController.dispose();
    _horarioCierreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      appBar: SmartAppBar(
        title: 'Crear Grifo',
        showUserInfo: true,
        logoPath: 'assets/img/6.svg',
        onLeftTap: () => Navigator.pop(context),
      ),
      body: BlocConsumer<GrifoBloc, GrifoState>(
        listener: _blocListener,
        builder: (context, state) {
          return Column(
            children: [
              // ⭐ FORMULARIO
              Expanded(
                flex: keyboardVisible ? 1 : 7,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 5),
                        _buildSedeDropdown(state),
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
                ),
              ),

              // ⭐ DIVISOR
              if (state.grifos.isNotEmpty && !keyboardVisible)
                Container(
                  height: 1,
                  color: AppColors.grey,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),

              // ⭐ LISTA DE GRIFOS
              if (state.grifos.isNotEmpty && !keyboardVisible)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'GRIFOS REGISTRADOS (${state.grifos.length})',
                          style: AppFont.oxygenBold.style(
                            fontSize: 10,
                            color: AppColors.blue3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.grifos.length,
                            itemBuilder: (context, index) {
                              final grifo = state.grifos[index];
                              return Card(
                                color: AppColors.white,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: grifo.activo == true
                                        ? Colors.green
                                        : Colors.red,
                                    child: Icon(
                                      Icons.local_gas_station,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    grifo.nombre,
                                    style: AppFont.oxygenBold.style(fontSize: 10),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        grifo.codigo ?? 'N/A',
                                        style: AppFont.oxygenRegular.style(fontSize: 8),
                                      ),
                                      if (grifo.sede != null)
                                        Text(
                                          'Sede: ${grifo.sede!.nombre}',
                                          style: AppFont.oxygenRegular.style(
                                            fontSize: 8,
                                            color: AppColors.blue3,
                                          ),
                                        ),
                                      if (grifo.horarioApertura != null && grifo.horarioCierre != null)
                                        Text(
                                          '${grifo.horarioApertura} - ${grifo.horarioCierre}',
                                          style: AppFont.oxygenRegular.style(
                                            fontSize: 8,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: grifo.estaAbierto == true
                                              ? Colors.green.withValues(alpha: 0.2)
                                              : Colors.red.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          grifo.estaAbierto == true ? 'Abierto' : 'Cerrado',
                                          style: AppFont.pirulentBold.style(
                                            fontSize: 7,
                                            color: grifo.estaAbierto == true
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${grifo.ticketsAbastecimientoCount ?? 0} tickets',
                                        style: AppFont.pirulentBold.style(fontSize: 7),
                                      ),
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
                ),
            ],
          );
        },
      ),
    );
  }

  // ========== LISTENER ==========

  void _blocListener(BuildContext context, GrifoState state) {
    if (state.createGrifoResponse != null) {
      if (state.createGrifoResponse is Success) {
        final grifo = (state.createGrifoResponse as Success).data;
        _showSuccessSnackbar('Grifo "${grifo.nombre}" creado exitosamente');
        _clearForm();
      } else if (state.createGrifoResponse is Error) {
        final errorMsg = (state.createGrifoResponse as Error).message;
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
          'NUEVO GRIFO',
          style: AppFont.oxygenBold.style(fontSize: 10, color: AppColors.blue3),
        ),
        // const SizedBox(height: 8),
        Text(
          'Complete los datos para registrar un nuevo grifo',
          style: AppFont.oxygenRegular.style(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSedeDropdown(GrifoState state) {
    return CustomDropdown2<SedeDropdownItem>(
      label: 'Sede *',
      hint: 'Seleccione una sede',
      selectedId: state.selectedSedeId,
      items: state.sedes.map((sede) => SedeDropdownItem(sede)).toList(),
      errorText: state.sedeError,
      isLoading: state.isLoadingSedes,
      borderColor: AppColors.blue3,
      iconColor: AppColors.blue3,
      itemTextStyle: AppFont.oxygenRegular.style(fontSize: 10),
      codeTextStyle: AppFont.oxygenBold.style(
        fontSize: 8,
        color: AppColors.grey,
      ),
      onChanged: (id) {
        if (id != null) {
          context.read<GrifoBloc>().add(GrifoSedeSelectedEvent(id));
        }
      },
    );
  }

  Widget _buildNombreField(GrifoState state) {
    return CustomTextField(
      controller: _nombreController,
      textCase: TextCase.upper,
      label: 'Nombre *',
      hintText: 'Ej: Grifo Central A',
      prefixIcon: const Icon(Icons.local_gas_station_outlined),
      borderColor: AppColors.blue3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nombre de grifo es requerido';
        }
        if (value.trim().length < 4) {
          return 'Debe tener al menos 4 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        context.read<GrifoBloc>().add(GrifoNameChangedEvent(value));
      },
    );
  }

  Widget _buildCodigoField(GrifoState state) {
    return CustomTextField(
      controller: _codigoController,
      label: 'Código *',
      hintText: 'Ej: GRF001',
      textCase: TextCase.upper,
      prefixIcon: const Icon(Icons.code_rounded),
      borderColor: AppColors.blue3,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Código de grifo es requerido';
        }
        if (value.trim().length < 4) {
          return 'Debe tener al menos 4 caracteres';
        }
        return null;
      },
      onChanged: (value) {
        context.read<GrifoBloc>().add(GrifoCodigoChangedEvent(value));
      },
    );
  }

  Widget _buildDireccionField(GrifoState state) {
    return CustomTextField(
      label: 'Dirección',
      textCase: TextCase.upper,
      hintText: 'Dirección del grifo',
      controller: _direccionController,
      prefixIcon: const Icon(Icons.location_on_outlined),
      borderColor: AppColors.blue3,
      enableRealTimeValidation: false,
      onChanged: (value) {
        context.read<GrifoBloc>().add(GrifoDireccionChangedEvent(value));
      },
    );
  }

  Widget _buildTelefonoField(GrifoState state) {
    return CustomTextFieldHelpers.phone(
      label: 'Teléfono',
      hintText: 'Teléfono de contacto',
      controller: _telefonoController,
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
    return CustomButton(
      text: 'Crear Grifo',
      onPressed: state.isFormValid && !state.isLoading
          ? () => _submitForm(state)
          : null,
      enabled: state.isFormValid && !state.isLoading,
      buttonState: state.isLoading ? ButtonState.loading : ButtonState.idle,
      backgroundColor: state.isFormValid ? AppColors.blue3 : AppColors.grey,
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

      context.read<GrifoBloc>().add(CreateGrifoEvent(request));
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _codigoController.clear();
    _direccionController.clear();
    _telefonoController.clear();
    _horarioAperturaController.clear();
    _horarioCierreController.clear();
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
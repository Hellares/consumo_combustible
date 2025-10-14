import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/custom_dropdown2.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/dropdown_adapters.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_bloc.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_event.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateSedePage extends StatefulWidget {
  const CreateSedePage({super.key});

  @override
  State<CreateSedePage> createState() => _CreateSedePageState();
}

class _CreateSedePageState extends State<CreateSedePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SedeBloc>().add(const InitSedeFormEvent());
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  // DETECTAR SI EL TECLADO ESTÁ VISIBLE
  final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

  return Scaffold(
    backgroundColor: AppColors.white,
    resizeToAvoidBottomInset: true,
    appBar: SmartAppBar(
      title: 'Crear Sede',
      showUserInfo: true,
      logoPath: 'assets/img/6.svg',
      onLeftTap: () => Navigator.pop(context),
    ),
    body: BlocConsumer<SedeBloc, SedeState>(
      listener: _blocListener,
      builder: (context, state) {
        return Column(
          children: [
            //  FORMULARIO - Ocupa todo el espacio cuando el teclado está visible
            Expanded(
              flex: keyboardVisible ? 1 : 7, // ⭐ Flex dinámico
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildZonaDropdown(state),
                      const SizedBox(height: 16),
                      _buildNombreField(state),
                      const SizedBox(height: 16),
                      _buildCodigoField(state),
                      const SizedBox(height: 16),
                      _buildDireccionField(state),
                      const SizedBox(height: 16),
                      _buildTelefonoField(state),
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

            // ⭐ DIVISOR - Solo visible cuando NO hay teclado
            if (state.sedes.isNotEmpty && !keyboardVisible)
              Container(
                height: 1,
                color: AppColors.grey,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),

            // LISTA DE SEDES - Solo visible cuando NO hay teclado
            if (state.sedes.isNotEmpty && !keyboardVisible)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        'SEDES REGISTRADAS (${state.sedes.length})',
                        style: AppFont.oxygenBold.style(
                          fontSize: 10,
                          color: AppColors.blue3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Expanded(
                        child: RepaintBoundary(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.sedes.length,
                            itemBuilder: (context, index) {
                              final sede = state.sedes[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                color: AppColors.white,
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  dense: true,
                                  leading: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: sede.activo == true 
                                        ? Colors.green 
                                        : Colors.red,
                                    child: Text(
                                      sede.codigo.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white, 
                                        fontSize: 10
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    sede.nombre,
                                    style: AppFont.oxygenBold.style(fontSize: 10),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sede.codigo,
                                        style: AppFont.oxygenRegular.style(fontSize: 8),
                                      ),
                                      if (sede.zona != null)
                                        Text(
                                          'Zona: ${sede.zona!.nombre}',
                                          style: AppFont.oxygenRegular.style(
                                            fontSize: 8,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${sede.grifosCount ?? 0} grifos',
                                        style: AppFont.pirulentBold.style(fontSize: 8),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
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

  void _blocListener(BuildContext context, SedeState state) {
    if (state.createSedeResponse != null) {
      if (state.createSedeResponse is Success) {
        final sede = (state.createSedeResponse as Success).data;
        _showSuccessSnackbar('Sede "${sede.nombre}" creada exitosamente');
        _clearForm();
      } else if (state.createSedeResponse is Error) {
        final errorMsg = (state.createSedeResponse as Error).message;
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
          'NUEVA SEDE',
          style: AppFont.oxygenBold.style(fontSize: 10, color: AppColors.blue3),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete los datos para registrar una nueva sede',
          style: AppFont.oxygenRegular.style(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

//   Widget _buildZonaDropdown(SedeState state) {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         'Zona *',
//         style: AppFont.oxygenBold.style(
//           fontSize: 10,
//           color: AppColors.blue3,
//         ),
//       ),
//       const SizedBox(height: 8),
//       Container(
//         height: 35,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: state.zonaError != null ? Colors.red : AppColors.blue3,
//             width: 0.5,
//           ),
//           borderRadius: BorderRadius.circular(6),
//           color: AppColors.white,
//         ),
//         child: state.isLoadingZonas
//             ? const Center(
//                 child: SizedBox(
//                   height: 20,
//                   width: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               )
//             : DropdownButtonHideUnderline(
//                 child: DropdownButton<int>(
//                   value: state.selectedZonaId,
//                   hint: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     child: Text(
//                       'Seleccione una zona',
//                       style: AppFont.oxygenRegular.style(
//                         fontSize: 10,
//                         color: AppColors.grey,
//                       ),
//                     ),
//                   ),
//                   isExpanded: true,
//                   icon: Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: Icon(
//                       Icons.arrow_drop_down,
//                       color: AppColors.blue3,
//                       size: 20,
//                     ),
//                   ),
//                   // ⭐ OPTIMIZACIÓN: Cachear items del dropdown
//                   items: state.zonas.map((zona) {
//                     return DropdownMenuItem<int>(
//                       value: zona.id,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         child: Row(
//                           children: [
//                             CircleAvatar(
//                               radius: 10,
//                               backgroundColor: zona.activo 
//                                   ? Colors.green 
//                                   : Colors.red,
//                               child: Text(
//                                 zona.codigo.isNotEmpty 
//                                     ? zona.codigo.substring(0, 1).toUpperCase()
//                                     : 'Z',
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 8,
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 zona.nombre,
//                                 style: AppFont.oxygenRegular.style(
//                                   fontSize: 10,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                             Text(
//                               zona.codigo,
//                               style: AppFont.oxygenBold.style(
//                                 fontSize: 8,
//                                 color: AppColors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       context.read<SedeBloc>().add(
//                             SedeZonaSelectedEvent(value),
//                           );
//                     }
//                   },
//                 ),
//               ),
//       ),
//       if (state.zonaError != null)
//         Padding(
//           padding: const EdgeInsets.only(top: 4, left: 12),
//           child: Text(
//             state.zonaError!,
//             style: const TextStyle(
//               color: Colors.red,
//               fontSize: 8,
//             ),
//           ),
//         ),
//     ],
//   );
// }

  Widget _buildZonaDropdown(SedeState state) {
  return CustomDropdown2<ZonaDropdownItem>(
    label: 'Zona *',
    hint: 'Seleccione una zona',
    selectedId: state.selectedZonaId, //  Simplemente pasas el ID
    items: state.zonas.map((zona) => ZonaDropdownItem(zona)).toList(),
    errorText: state.zonaError,
    isLoading: state.isLoadingZonas,
    borderColor: AppColors.blue3,
    iconColor: AppColors.blue3,
    itemTextStyle: AppFont.oxygenRegular.style(fontSize: 10),
    codeTextStyle: AppFont.oxygenBold.style(
      fontSize: 8,
      color: AppColors.grey,
    ),
    onChanged: (id) { //  Recibes el ID directamente
      if (id != null) {
        context.read<SedeBloc>().add(SedeZonaSelectedEvent(id));
      }
    },
  );
}

  Widget _buildNombreField(SedeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nombreController,
          label: 'Nombre *',
          hintText: 'Ej: Sede Pacasmayo',
          prefixIcon: const Icon(Icons.business_outlined),
          borderColor: AppColors.blue3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nombre de sede es requerido';
            }
            if (value.trim().length < 4) {
              return 'Debe tener al menos 4 caracteres';
            }
            return null;
          },
          onChanged: (value) {
            context.read<SedeBloc>().add(SedeNameChangedEvent(value));
          },
        ),
      ],
    );
  }

  Widget _buildCodigoField(SedeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _codigoController,
          label: 'Código *',
          hintText: 'Ej: SEDE01',
          textCase: TextCase.upper,
          prefixIcon: const Icon(Icons.code_rounded),
          borderColor: AppColors.blue3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Código de sede es requerido';
            }
            if (value.trim().length < 4) {
              return 'Debe tener al menos 4 caracteres';
            }
            return null;
          },
          onChanged: (value) {
            context.read<SedeBloc>().add(SedeCodigoChangedEvent(value));
          },
        )
      ],
    );
  }

  Widget _buildDireccionField(SedeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Dirección',
          hintText: 'Dirección de la sede',
          controller: _direccionController,
          prefixIcon: const Icon(Icons.location_on_outlined),
          borderColor: AppColors.blue3,
          enableRealTimeValidation: false,
          onChanged: (value) {
            context.read<SedeBloc>().add(SedeDireccionChangedEvent(value));
          },
        )
      ],
    );
  }

  Widget _buildTelefonoField(SedeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'Teléfono',
          hintText: 'Teléfono de contacto',
          controller: _telefonoController,
          prefixIcon: const Icon(Icons.phone_outlined),
          borderColor: AppColors.blue3,
          enableRealTimeValidation: false,
          onChanged: (value) {
            context.read<SedeBloc>().add(SedeTelefonoChangedEvent(value));
          },
        )
      ],
    );
  }

  Widget _buildActivoSwitch(SedeState state) {
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
                  context.read<SedeBloc>().add(SedeActivoChangedEvent(value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(SedeState state) {
    return CustomButton(
      text: 'Crear Sede',
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

  void _submitForm(SedeState state) {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateSedeRequest(
        zonaId: state.selectedZonaId!,
        nombre: state.nombre.trim(),
        codigo: state.codigo.trim().toUpperCase(),
        direccion: state.direccion.trim().isNotEmpty 
            ? state.direccion.trim() 
            : null,
        telefono: state.telefono.trim().isNotEmpty 
            ? state.telefono.trim() 
            : null,
        activo: state.activo,
      );

      context.read<SedeBloc>().add(CreateSedeEvent(request));
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _codigoController.clear();
    _direccionController.clear();
    _telefonoController.clear();
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
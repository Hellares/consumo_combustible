import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_date.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/core/widgets/user_selector_field.dart'; // ✅ NUEVO IMPORT
import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
import 'package:consumo_combustible/domain/models/user_selection.dart'; // ✅ NUEVO IMPORT
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_bloc.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_event.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreateLicenciaPage extends StatefulWidget {
  const CreateLicenciaPage({super.key});

  @override
  State<CreateLicenciaPage> createState() => _CreateLicenciaPageState();
}

class _CreateLicenciaPageState extends State<CreateLicenciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _numeroLicenciaController = TextEditingController();
  final _categoriaController = TextEditingController();
  
  // ✅ MODIFICADO - Ya no necesitamos estos controllers, pero los dejamos por compatibilidad
  final _usuarioIdController = TextEditingController();
  final _usuarioNombreController = TextEditingController();
  
  // ✅ NUEVO - Variable para almacenar el usuario seleccionado
  UserSelection? _selectedUser;
  
  DateTime? _fechaEmision;
  DateTime? _fechaExpiracion;

  final List<String> _categorias = [
    'A-I',
    'A-IIA',
    'A-IIB',
    'A-IIIA',
    'A-IIIB',
    'A-IIIC',
    'B-I',
    'B-IIA',
    'B-IIB',
    'B-IIC',
  ];

  @override
  void dispose() {
    _numeroLicenciaController.dispose();
    _categoriaController.dispose();
    _usuarioIdController.dispose();
    _usuarioNombreController.dispose();
    super.dispose();
  }


  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // ✅ MODIFICADO - Validar usuario seleccionado
      if (_selectedUser == null) {
        SnackBarHelper.showError(context, 'Debe seleccionar un usuario');
        return;
      }

      if (_fechaEmision == null) {
        SnackBarHelper.showError(context, 'Debe seleccionar la fecha de emisión');
        return;
      }

      if (_fechaExpiracion == null) {
        SnackBarHelper.showError(context, 'Debe seleccionar la fecha de expiración');
        return;
      }

      // ✅ MODIFICADO - Usar el ID del usuario seleccionado
      final request = CreateLicenciaRequest(
        usuarioId: _selectedUser!.id,
        numeroLicencia: _numeroLicenciaController.text.trim(),
        categoria: _categoriaController.text.trim(),
        fechaEmision: DateFormat('yyyy-MM-dd').format(_fechaEmision!),
        fechaExpiracion: DateFormat('yyyy-MM-dd').format(_fechaExpiracion!),
      );

      context.read<LicenciaBloc>().add(CreateLicencia(request));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar(title: 'Nueva Licencia de Conducir', showLogo: true, logoPath: 'assets/img/6.svg',),
      body: BlocConsumer<LicenciaBloc, LicenciaState>(
        listener: (context, state) {
          if (state.response is Success) {
            SnackBarHelper.showSuccess(context, 'Licencia creada exitosamente');
            Navigator.pop(context, true);
          } else if (state.response is Error) {
            final error = state.response as Error;
            SnackBarHelper.showError(context, error.message);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserSelectorField(
                    height: 35,
                    label: 'Conductor',
                    hintText: 'Seleccionar conductor',
                    roleFilter: null, //!'ADMIN', // Solo muestra usuarios con rol CONDUCTOR
                    isRequired: true,
                    borderColor: AppColors.blue3,
                    onUserSelected: (user) {
                      setState(() {
                        _selectedUser = user;
                        // Actualizar controllers por compatibilidad (opcional)
                        _usuarioIdController.text = user.id.toString();
                        _usuarioNombreController.text = user.nombreCompleto;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  
                  CustomTextField(
                    controller: _numeroLicenciaController,
                    label: 'Número de Licencia',
                    hintText: 'Ej: Q12300679 ',
                    prefixIcon: const Icon(Icons.badge),
                    borderColor: AppColors.blue3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El número de licencia es requerido';
                      }
                      if (value.trim().length < 5) {
                        return 'El número debe tener al menos 5 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomDropdown(
                    label: 'Categoría',
                    hintText: 'Seleccionar categoría',
                    items: _categorias.map((categoria){
                      return DropdownItem(
                        value: categoria,
                        label: categoria, // Usar el valor de la categoría, no texto fijo
                      );
                    }).toList(),
                    value: _categoriaController.text.isEmpty ? null : _categoriaController.text,
                    borderColor: AppColors.blue3,
                    onChanged: (value){
                      setState(() {
                        _categoriaController.text = value ?? '';
                      });
                    },
                    validator: (value){
                      if (value == null || value.isEmpty){
                        return 'La categoria es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Emisión
                  CustomDate(
                    label: 'Fecha de Emisión',
                    hintText: 'Seleccionar fecha de emisión',
                    borderColor: AppColors.blue3,
                    initialDate: _fechaEmision,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    onDateSelected: (date) {
                      setState(() {
                        _fechaEmision = date;
                      });
                    },
                    validator: (value) {
                      if (_fechaEmision == null) {
                        return 'La fecha de emisión es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Expiración
                  CustomDate(
                    label: 'Fecha de Expiración',
                    hintText: 'Seleccionar fecha de expiración',
                    borderColor: AppColors.blue3,
                    initialDate: _fechaExpiracion,
                    firstDate: _fechaEmision ?? DateTime.now(),
                    lastDate: DateTime(2050),
                    onDateSelected: (date) {
                      setState(() {
                        _fechaExpiracion = date;
                      });
                    },
                    validator: (value) {
                      if (_fechaExpiracion == null) {
                        return 'La fecha de expiración es requerida';
                      }
                      if (_fechaEmision != null && _fechaExpiracion!.isBefore(_fechaEmision!)) {
                        return 'Debe ser posterior a la fecha de emisión';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue3,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : AppTitle('Crear Licencia',color: AppColors.white, font: AppFont.pirulentBold, fontSize: 10,)
                        // : const Text(
                        //     'Crear Licencia',
                        //     style: TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ ELIMINADO - Ya no necesitamos _buildUsuarioField() ni _showUserSearchDialog()
  // El widget UserSelectorField maneja todo esto automáticamente
}
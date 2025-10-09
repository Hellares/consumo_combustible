import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_date.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterUserDialog extends StatefulWidget {
  final Function(RegisterUserRequest) onRegister;

  const RegisterUserDialog({
    super.key,
    required this.onRegister,
  });

  @override
  State<RegisterUserDialog> createState() => _RegisterUserDialogState();
}

class _RegisterUserDialogState extends State<RegisterUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _dniController = TextEditingController();
  final _fechaIngresoController = TextEditingController();
  final FocusNode _nombresFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // No enfoques aquí, para evitar rebote
  }

  bool _isLoading = false;

  @override
  void dispose() {
    _nombresFocus.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _dniController.dispose();
    _fechaIngresoController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Convertir fecha a formato YYYY-MM-DD
      String fechaIngreso;
      if (_fechaIngresoController.text.isNotEmpty) {
        // Parsear la fecha del controller (formato dd/MM/yyyy)
        try {
          final parts = _fechaIngresoController.text.split('/');
          if (parts.length == 3) {
            final year = parts[2];
            final month = parts[1].padLeft(2, '0');
            final day = parts[0].padLeft(2, '0');
            fechaIngreso = '$year-$month-$day';
          } else {
            // Fallback: usar fecha actual
            fechaIngreso = DateFormat('yyyy-MM-dd').format(DateTime.now());
          }
        } catch (e) {
          // Si hay error, usar fecha actual
          fechaIngreso = DateFormat('yyyy-MM-dd').format(DateTime.now());
        }
      } else {
        // Si está vacío, usar fecha actual
        fechaIngreso = DateFormat('yyyy-MM-dd').format(DateTime.now());
      }

      final request = RegisterUserRequest(
        nombres: _nombresController.text.trim().toUpperCase(),
        apellidos: _apellidosController.text.trim().toUpperCase(),
        email: _emailController.text.trim().toLowerCase(),
        telefono: _telefonoController.text.trim(),
        dni: _dniController.text.trim(),
        fechaIngreso: fechaIngreso,
      );

      widget.onRegister(request);
    }
  }

  @override
  void didChangeDependencies() { // ⭐ NUEVO: Enfoca después del primer build
    super.didChangeDependencies();
    if (_nombresFocus.hasFocus == false) {
      _nombresFocus.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: RepaintBoundary(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: FocusScope(
                // canRequestFocus: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.person_add_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registrar Usuario',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blue,
                                ),
                              ),
                              Text(
                                'Complete los datos del nuevo usuario',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                
                    const SizedBox(height: 20),
                
                    // Formulario
                    CustomTextField(
                      focusNode: _nombresFocus,
                      label: 'Nombres',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      controller: _nombresController,
                      hintText: 'Ingrese los nombres',
                      borderColor: AppColors.blue3,
                      prefixIcon: Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los nombres son requeridos';
                        }
                        if (value.trim().length < 2) {
                          return 'Debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                
                    const SizedBox(height: 12),
                
                    CustomTextField(
                      label: 'Apellidos',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      
                      controller: _apellidosController,
                      hintText: 'Ingrese los apellidos',
                      prefixIcon: Icon(Icons.person),
                      borderColor: AppColors.blue3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Los apellidos son requeridos';
                        }
                        if (value.trim().length < 2) {
                          return 'Debe tener al menos 2 caracteres';
                        }
                        return null;
                      },
                    ),
                
                    const SizedBox(height: 12),
                
                    CustomTextField(
                      label: 'Email',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      borderColor: AppColors.blue3,
                      controller: _emailController,
                      hintText: 'ejemplo@empresa.com',
                      fieldType: FieldType.email,
                      // enableRealTimeValidation: false,
                
                    ),
                
                    const SizedBox(height: 12),
                
                    CustomTextField(
                      label: 'Teléfono',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      borderColor: AppColors.blue3,
                      controller: _telefonoController,
                      hintText: 'Ingrese el teléfono',
                      fieldType: FieldType.phone,
                      enableRealTimeValidation: false,
                    ),
                
                    const SizedBox(height: 12),
                
                    CustomTextField(
                      label: 'DNI',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      borderColor: AppColors.blue3,
                      controller: _dniController,
                      hintText: '12345678',
                      fieldType: FieldType.dni,
                      enableRealTimeValidation: false,
                
                    ),
                
                    const SizedBox(height: 12),
                
                    CustomDate(
                      label: 'Fecha de Ingreso',
                      labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
                      borderColor: AppColors.blue3,
                      controller: _fechaIngresoController,
                      hintText: 'Seleccione la fecha de ingreso',
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                      initialDate: DateTime.now(),
                    ),
                
                    const SizedBox(height: 16),
                
                    // Nota informativa
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blue[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'El usuario será creado con rol USER por defecto',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 20),
                
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Cancelar',
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            backgroundColor: Colors.grey[300],
                            textColor: Colors.grey[800]!,
                            enabled: !_isLoading,
                            enableShadows: false,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: 'Registrar',
                            onPressed: _handleRegister,
                            buttonState: _isLoading ? ButtonState.loading : ButtonState.idle,
                            loadingText: 'Registrando...',
                            gradient: LinearGradient(
                              colors: [Colors.blue[400]!, Colors.blue[600]!],
                            ),
                            textColor: Colors.white,
                            enabled: !_isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
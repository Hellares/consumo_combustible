// lib/presentation/page/licencias/create_licencia_page.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
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
  final _usuarioIdController = TextEditingController();
  final _usuarioNombreController = TextEditingController();
  
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

  Future<void> _selectDate(BuildContext context, bool isEmision) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEmision 
          ? (_fechaEmision ?? DateTime.now())
          : (_fechaExpiracion ?? DateTime.now().add(const Duration(days: 365 * 5))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.blue3,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isEmision) {
          _fechaEmision = picked;
        } else {
          _fechaExpiracion = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_usuarioIdController.text.isEmpty) {
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

      final request = CreateLicenciaRequest(
        usuarioId: int.parse(_usuarioIdController.text),
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
      appBar: AppBar(
        title: const Text('Nueva Licencia de Conducir'),
        backgroundColor: AppColors.blue3,
        foregroundColor: Colors.white,
      ),
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
                  // Usuario
                  _buildUsuarioField(),
                  const SizedBox(height: 16),

                  // Número de Licencia
                  TextFormField(
                    controller: _numeroLicenciaController,
                    decoration: InputDecoration(
                      labelText: 'Número de Licencia',
                      hintText: 'Ej: Q12300679',
                      prefixIcon: const Icon(Icons.badge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.characters,
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

                  // Categoría
                  DropdownButtonFormField<String>(
                    initialValue: _categoriaController.text.isEmpty ? null : _categoriaController.text,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _categorias.map((categoria) {
                      return DropdownMenuItem(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _categoriaController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'La categoría es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Emisión
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de Emisión',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _fechaEmision == null
                            ? 'Seleccionar fecha'
                            : DateFormat('dd/MM/yyyy').format(_fechaEmision!),
                        style: TextStyle(
                          color: _fechaEmision == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Expiración
                  InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Fecha de Expiración',
                        prefixIcon: const Icon(Icons.event),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _fechaExpiracion == null
                            ? 'Seleccionar fecha'
                            : DateFormat('dd/MM/yyyy').format(_fechaExpiracion!),
                        style: TextStyle(
                          color: _fechaExpiracion == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar
                  ElevatedButton(
                    onPressed: state.isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue3,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                        : const Text(
                            'Crear Licencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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

  Widget _buildUsuarioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _usuarioNombreController,
          decoration: InputDecoration(
            labelText: 'Usuario',
            hintText: 'Buscar usuario por DNI o nombre',
            prefixIcon: const Icon(Icons.person_search),
            suffixIcon: _usuarioIdController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _usuarioIdController.clear();
                        _usuarioNombreController.clear();
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          readOnly: true,
          onTap: () => _showUserSearchDialog(),
          validator: (value) {
            if (_usuarioIdController.text.isEmpty) {
              return 'Debe seleccionar un usuario';
            }
            return null;
          },
        ),
        if (_usuarioIdController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              'ID: ${_usuarioIdController.text}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  void _showUserSearchDialog() {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Buscar Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Ingrese ID del usuario',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const Text(
              'Por ahora, ingrese el ID del usuario directamente. La búsqueda avanzada estará disponible próximamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                setState(() {
                  _usuarioIdController.text = searchController.text;
                  _usuarioNombreController.text = 'Usuario ID: ${searchController.text}';
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue3,
            ),
            child: const Text('Seleccionar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
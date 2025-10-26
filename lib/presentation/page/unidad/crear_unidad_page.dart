// lib/presentation/page/unidades/crear_unidad_page.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_date.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/user_selector_field.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/models/create_unidad_request.dart';
import 'package:consumo_combustible/domain/models/user_selection.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/use_cases/zona/zona_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_bloc.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_event.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CrearUnidadPage extends StatefulWidget {
  const CrearUnidadPage({super.key});

  @override
  State<CrearUnidadPage> createState() => _CrearUnidadPageState();
}

class _CrearUnidadPageState extends State<CrearUnidadPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _placaController = TextEditingController();
  final _operacionController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _anioController = TextEditingController();
  final _nroVinController = TextEditingController();
  final _nroMotorController = TextEditingController();
  final _capacidadTanqueController = TextEditingController();
  final _odometroInicialController = TextEditingController();
  final _horometroInicialController = TextEditingController();
  final _fechaAdquisicionController = TextEditingController();

  // Selecciones
  UserSelection? _selectedConductor;
  int? _selectedZonaId;
  String _selectedTipoCombustible = 'DIESEL';
  String _selectedEstado = 'OPERATIVO';
  
  // Listas para dropdowns
  List<Zona> zonas = [];
  
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    
    // Valores por defecto
    _anioController.text = DateTime.now().year.toString();
    // Formato correcto para la base de datos: YYYY-MM-DD
    final now = DateTime.now();
    _fechaAdquisicionController.text = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _odometroInicialController.text = '0';
    _horometroInicialController.text = '0';
    _capacidadTanqueController.text = '0';
  }

  Future<void> _loadInitialData() async {
    try {
      // Cargar zonas
      final zonaUseCases = locator<ZonaUseCases>();
      final zonasResult = await zonaUseCases.getZonas.run();
      
      if (mounted) {
        setState(() {
          if (zonasResult is Success<List<Zona>>) {
            zonas = zonasResult.data;
          }
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _placaController.dispose();
    _operacionController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _nroVinController.dispose();
    _nroMotorController.dispose();
    _capacidadTanqueController.dispose();
    _odometroInicialController.dispose();
    _horometroInicialController.dispose();
    _fechaAdquisicionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos requeridos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedConductor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un conductor'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedZonaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una zona'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final request = CreateUnidadRequest(
      placa: _placaController.text.trim().toUpperCase(),
      conductorOperadorId: _selectedConductor!.id,
      operacion: _operacionController.text.trim(),
      marca: _marcaController.text.trim(),
      modelo: _modeloController.text.trim(),
      anio: int.parse(_anioController.text),
      nroVin: _nroVinController.text.trim(),
      nroMotor: _nroMotorController.text.trim(),
      zonaOperacionId: _selectedZonaId!,
      capacidadTanque: double.parse(_capacidadTanqueController.text),
      tipoCombustible: _selectedTipoCombustible,
      odometroInicial: double.parse(_odometroInicialController.text),
      horometroInicial: double.parse(_horometroInicialController.text),
      fechaAdquisicion: _fechaAdquisicionController.text,
      estado: _selectedEstado,
      activo: true,
    );

    context.read<UnidadBloc>().add(CreateUnidad(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Nueva Unidad',
        showLogo: true,
        logoPath: ApiConfig.logoLottiePath,
      ),
      body: BlocConsumer<UnidadBloc, UnidadState>(
        listener: (context, state) {
          if (state.status == UnidadStatus.created) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unidad ${state.createdUnidad?.placa} creada exitosamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            
            // Resetear estado y volver atrás
            context.read<UnidadBloc>().add(const ResetCreateUnidadState());
            Navigator.pop(context);
          }

          if (state.status == UnidadStatus.createError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.createErrorMessage ?? 'Error al crear unidad'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isCreating = state.status == UnidadStatus.creating;

          if (_isLoadingData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Sección: Información Básica
                _buildSectionHeader('Información Básica'),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _placaController,
                  borderColor: AppColors.blue3,
                  label: 'Placa *',
                  hintText: 'ABC-123',
                  prefixIcon: Icon(Icons.confirmation_number),
                  enabled: !isCreating,
                  textCase: TextCase.upper,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La placa es requerida';
                    }
                    if (value.length < 6) {
                      return 'Placa inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Selector de Conductor
                UserSelectorField(
                  height: 35,
                  label: 'Conductor',
                  hintText: 'Seleccionar conductor',
                  roleFilter: 'CONDUCTOR', // null = todos los usuarios o demas roles a filtrar
                  isRequired: true,
                  borderColor: AppColors.blue3,
                  onUserSelected: (user) {
                    setState(() {
                      _selectedConductor = user;
                    });
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _operacionController,
                  label: 'Operación *',
                  hintText: 'Transporte de Carga',
                  borderColor: AppColors.blue3,
                  prefixIcon: Icon(Icons.work_outline_outlined),                  
                  enabled: !isCreating,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La operación es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Sección: Vehículo
                _buildSectionHeader('Datos del Vehículo'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _marcaController,
                        label: 'Marca *',
                        hintText: 'VOLVO',
                        borderColor: AppColors.blue3,
                        textCase: TextCase.upper,
                        prefixIcon: Icon(Icons.branding_watermark_outlined, size: 18,),
                        enabled: !isCreating,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _modeloController,
                        label: 'Modelo *',
                        hintText: 'FH 460',
                        textCase: TextCase.upper,
                        borderColor: AppColors.blue3,
                        prefixIcon: Icon(Icons.directions_car),
                        enabled: !isCreating,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _anioController,
                        label: 'Año *',
                        hintText: '2020',
                        // prefixIcon: Icons.calendar_today,
                        prefixIcon: Icon(Icons.calendar_today,size: 16,),
                        borderColor: AppColors.blue3,
                        keyboardType: TextInputType.number,
                        enabled: !isCreating,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final anio = int.tryParse(value);
                          if (anio == null || anio < 1900 || anio > DateTime.now().year + 1) {
                            return 'Año inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomDate(
                        controller: _fechaAdquisicionController,
                        label: 'Fecha Adquisición *',
                        dateFormat: 'yyyy-MM-dd', // Formato para la base de datos
                        borderColor: AppColors.blue3,
                        enabled: !isCreating,
                        onDateSelected: (date) {
                          if (date != null) {
                            // Asegurar formato YYYY-MM-DD
                            final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            _fechaAdquisicionController.text = formatted;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nroVinController,
                  label: 'Número VIN *',
                  borderColor: AppColors.blue3,
                  hintText: 'YV2A1234567890123',
                  textCase: TextCase.upper,
                  prefixIcon: Icon(Icons.settings, size: 16,),
                  enabled: !isCreating,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El VIN es requerido';
                    }
                    if (value.length < 10) {
                      return 'VIN inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _nroMotorController,
                  borderColor: AppColors.blue3,
                  label: 'Número de Motor *',
                  hintText: 'D13F460EC06',
                  prefixIcon: Icon(Icons.build, size: 16,),
                  textCase: TextCase.upper,
                  enabled: !isCreating,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El número de motor es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sección: Combustible
                _buildSectionHeader('Combustible'),
                const SizedBox(height: 16),

                // Dropdown Zona usando CustomDropdown
                CustomDropdown<int>(
                  label: 'Zona de Operación *',
                  hintText: 'Seleccionar zona',
                  value: _selectedZonaId,
                  borderColor: AppColors.blue3,
                  enabled: !isCreating,
                  // maxHeight: 250,
                  items: zonas.map((zona) {
                    return DropdownItem<int>(
                      value: zona.id,
                      label: zona.nombre,
                      leading: Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.blue3,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedZonaId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debe seleccionar una zona';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown Tipo Combustible usando CustomDropdown
                CustomDropdown<String>(
                  label: 'Tipo de Combustible *',
                  hintText: 'Seleccionar combustible',
                  value: _selectedTipoCombustible,
                  borderColor: AppColors.blue3,
                  enabled: !isCreating,
                  items: ['DIESEL', 'GASOLINA_84', 'GASOLINA_90',  'GASOLINA_95',  'GASOLINA_97', 'GLP', 'GNV','ELECTRICO'].map((tipo) {
                    return DropdownItem<String>(
                      value: tipo,
                      label: tipo,
                      leading: Icon(
                        Icons.local_gas_station,
                        size: 18,
                        color: AppColors.blue3,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedTipoCombustible = value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debe seleccionar un tipo de combustible';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _capacidadTanqueController,
                  label: 'Capacidad del Tanque (Litros) *',
                  borderColor: AppColors.blue3,
                  hintText: '400',
                  prefixIcon: Icon(Icons.water_drop,size: 16,),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  enabled: !isCreating,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    final capacidad = double.tryParse(value);
                    if (capacidad == null || capacidad <= 0) {
                      return 'Capacidad inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Sección: Lecturas Iniciales
                _buildSectionHeader('Lecturas Iniciales'),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _odometroInicialController,
                        label: 'Odómetro (Km) *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.speed),
                        borderColor: AppColors.blue3,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: !isCreating,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final odometro = double.tryParse(value);
                          if (odometro == null || odometro < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _horometroInicialController,
                        label: 'Horómetro (Hrs) *',
                        hintText: '0',
                        prefixIcon: Icon(Icons.timer),
                        borderColor: AppColors.blue3,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        enabled: !isCreating,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Requerido';
                          }
                          final horometro = double.tryParse(value);
                          if (horometro == null || horometro < 0) {
                            return 'Inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sección: Estado
                _buildSectionHeader('Estado'),
                const SizedBox(height: 16),

                // Dropdown Estado usando CustomDropdown
                CustomDropdown<String>(
                  label: 'Estado Inicial *',
                  hintText: 'Seleccionar estado',
                  value: _selectedEstado,
                  borderColor: AppColors.blue3,
                  enabled: !isCreating,
                  maxHeight: 250, // Limitar altura para permitir scroll interno
                  items: ['OPERATIVO', 'MANTENIMIENTO_PREVENTIVO','MANTENIMIENTO_CORRECTIVO','AVERIADO', 'FUERA_SERVICIO'].map((estado) {
                    IconData iconData;
                    Color iconColor;
                    
                    switch (estado) {
                      case 'OPERATIVO':
                        iconData = Icons.check_circle;
                        iconColor = Colors.green;
                        break;
                      case 'MANTENIMIENTO_PREVENTIVO':
                        iconData = Icons.build;
                        iconColor = Colors.orange;
                        break;
                      case 'MANTENIMIENTO_CORRECTIVO':
                        iconData = Icons.build;
                        iconColor = Colors.orange;
                        break;
                      case 'AVERIADO':
                        iconData = Icons.error;
                        iconColor = Colors.red;
                        break;
                      default:
                        iconData = Icons.info;
                        iconColor = Colors.grey;
                    }
                    
                    return DropdownItem<String>(
                      value: estado,
                      label: estado,
                      leading: Icon(
                        iconData,
                        size: 14,
                        color: iconColor,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedEstado = value);
                    }
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Debe seleccionar un estado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Botón Guardar
                CustomButton(
                  text: 'Crear Unidad',
                  onPressed: isCreating ? null : _submitForm,
                  buttonState: isCreating ? ButtonState.loading : ButtonState.idle,
                  loadingText: 'Creando...',
                  backgroundColor: AppColors.blue3,
                  textStyle: TextStyle(fontFamily: AppFonts.getFontFamily(AppFont.pirulentBold),fontSize: 10),
                  
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 2,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        AppTitle(title,font: AppFont.pirulentBold,fontSize: 8,)
      ],
    );
  }

}
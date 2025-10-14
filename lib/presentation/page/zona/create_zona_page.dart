import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_bloc.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_event.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateZonaPage extends StatefulWidget {
  const CreateZonaPage({super.key});

  @override
  State<CreateZonaPage> createState() => _CreateZonaPageState();
}

class _CreateZonaPageState extends State<CreateZonaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ZonaBloc>().add(const InitZonaFormEvent());
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar(
        title: 'Crear Zona',
        showUserInfo: true,
        logoPath: 'assets/img/6.svg',
        onLeftTap: () => Navigator.pop(context),
      ),
      body: BlocConsumer<ZonaBloc, ZonaState>(
        listener: _blocListener,
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildNombreField(state),
                      const SizedBox(height: 16),
                      _buildCodigoField(state),
                      const SizedBox(height: 16),
                      _buildDescripcionField(state),
                      const SizedBox(height: 16),
                      _buildActivoSwitch(state),
                      const SizedBox(height: 15),
                      _buildSubmitButton(state),
                      const SizedBox(height: 5),
                      // if (state.zonas.isNotEmpty) _buildZonasList(state),
                    ],
                  ),
                ),
              ),
              if (state.zonas.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildZonasList(state),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ========== LISTENER ==========

  void _blocListener(BuildContext context, ZonaState state) {
    if (state.createZonaResponse != null) {
      if (state.createZonaResponse is Success) {
        final zona = (state.createZonaResponse as Success).data;
        _showSuccessSnackbar('Zona "${zona.nombre}" creada exitosamente');
        _clearForm();
      } else if (state.createZonaResponse is Error) {
        final errorMsg = (state.createZonaResponse as Error).message;
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
          'NUEVA ZONA',
          style: AppFont.oxygenBold.style(fontSize: 10, color: AppColors.blue3),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete los datos para registrar una nueva zona',
          style: AppFont.oxygenRegular.style(
            fontSize: 10,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNombreField(ZonaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nombreController,
          label: 'Nombre *',
          hintText: 'Ej: La Libertad',
          prefixIcon: Icon(Icons.location_on_outlined),
          borderColor: AppColors.blue3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nombre zona es requeridos';
            }
            if (value.trim().length < 4) {
              return 'Debe tener al menos 4 caracteres';
            }
            return null;
          },
          onChanged: (value) {
            context.read<ZonaBloc>().add(ZonaNameChangedEvent(value));
          },
        ),
      ],
    );
  }

  Widget _buildCodigoField(ZonaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _codigoController,
          label: 'Código *',
          hintText: 'Ej: PACASMAYO',
          textCase: TextCase.upper,
          prefixIcon: Icon(Icons.code_rounded),
          borderColor: AppColors.blue3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Código zona es requeridos';
            }
            if (value.trim().length < 4) {
              return 'Debe tener al menos 4 caracteres';
            }
            return null;
          },
          onChanged: (value) {
            context.read<ZonaBloc>().add(ZonaCodigoChangedEvent(value));
          },
        ),
      ],
    );
  }

  Widget _buildDescripcionField(ZonaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          height: 60,
          label: 'Descripción',
          hintText: 'Descripción opcional de la zona',
          controller: _descripcionController,
          maxLines: 3,
          borderColor: AppColors.blue3,
          enableRealTimeValidation: false,
          onChanged: (value) {
            context.read<ZonaBloc>().add(ZonaDescripcionChangedEvent(value));
          },
        ),
      ],
    );
  }

  Widget _buildActivoSwitch(ZonaState state) {
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
                color: state.activo ? AppColors.orange : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Transform.scale(
              scale: 0.6,
              child: Switch(
                value: state.activo,
                activeThumbColor: AppColors.orange,
                onChanged: (value) {
                  context.read<ZonaBloc>().add(ZonaActivoChangedEvent(value));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ZonaState state) {
    return CustomButton(
      text: 'Crear Zona',
      onPressed: state.isFormValid && !state.isLoading
          ? () => _submitForm(state)
          : null,
      enabled: state.isFormValid && !state.isLoading,
      buttonState: state.isLoading ? ButtonState.loading : ButtonState.idle,
      gradient: state.isFormValid
          ? null
          : null, // Usar color de fondo por defecto cuando está deshabilitado
      backgroundColor: state.isFormValid ? AppColors.blue3 : AppColors.grey,
      textColor: AppColors.white,
      height: 35,
      borderRadius: 16,
    );
  }

  Widget _buildZonasList(ZonaState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZONAS REGISTRADAS (${state.zonas.length})',
          style: AppFont.oxygenBold.style(fontSize: 10, color: AppColors.blue3),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            shrinkWrap: false,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.zonas.length,
            itemBuilder: (context, index) {
              final zona = state.zonas[index];
              return Card(
                color: AppColors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: zona.activo ? AppColors.orange : Colors.red,
                    child: Text(
                      zona.codigo.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  title: Text(
                    zona.nombre,
                    style: AppFont.oxygenBold.style(fontSize: 10),
                  ),
                  subtitle: Text(
                    zona.codigo,
                    style: AppFont.oxygenRegular.style(fontSize: 8),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${zona.sedesCount} sedes',
                        style: AppFont.pirulentBold.style(fontSize: 8),
                      ),
                      Text(
                        '${zona.unidadesCount} unidades',
                        style: AppFont.pirulentBold.style(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ========== HELPERS ==========

  void _submitForm(ZonaState state) {
    if (_formKey.currentState?.validate() ?? false) {
      final request = CreateZonaRequest(
        nombre: state.nombre.trim(),
        codigo: state.codigo.trim().toUpperCase(),
        descripcion: state.descripcion.trim(),
        activo: state.activo,
      );

      context.read<ZonaBloc>().add(CreateZonaEvent(request));
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _codigoController.clear();
    _descripcionController.clear();
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

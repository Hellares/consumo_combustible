import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_bloc.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_event.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_state.dart';
import 'package:consumo_combustible/presentation/page/rol/widgets/permisos_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateRolPage extends StatefulWidget {
  final Rol? rolToEdit;

  const CreateRolPage({
    super.key,
    this.rolToEdit,
  });

  @override
  State<CreateRolPage> createState() => _CreateRolPageState();
}

class _CreateRolPageState extends State<CreateRolPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();

  late CreateRolRequest _rolRequest;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.rolToEdit != null;

    if (_isEditing) {
      // Modo edición: cargar datos del rol
      final rol = widget.rolToEdit!;
      _nombreController.text = rol.nombre;
      _descripcionController.text = rol.descripcion ?? '';
      _rolRequest = CreateRolRequest(
        nombre: rol.nombre,
        descripcion: rol.descripcion,
        permisos: rol.permisos,
        activo: rol.activo,
      );
    } else {
      // Modo creación: inicializar con permisos vacíos
      _rolRequest = CreateRolRequest.empty();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar.basic(
        title: _isEditing ? 'Editar Rol' : 'Nuevo Rol',
        showLogo: false,
      ),
      body: GradientContainer(
        gradient: AppGradients.sinfondo,
        child: BlocConsumer<RolBloc, RolState>(
          listener: _handleBlocListener,
          builder: (context, state) {
            final isLoading = _isLoadingState(state);

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoSection(),
                          const SizedBox(height: 10),
                          _buildPermisosSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomButton(isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // === LISTENERS ===

  void _handleBlocListener(BuildContext context, RolState state) {
    // Manejo de creación exitosa
    if (state.createResponse != null) {
      if (state.createResponse is Success) {
        SnackBarHelper.showSuccess(
          context,
          'Rol creado exitosamente',
          // SnackBarType.success,
        );
        Navigator.pop(context, true); // Retornar true para recargar lista
      } else if (state.createResponse is Error) {
        final error = state.createResponse as Error;
        SnackBarHelper.showError(
          context,
          error.message,
          // SnackBarType.error,
        );
      }
    }

    // Manejo de actualización exitosa
    if (state.updateResponse != null) {
      if (state.updateResponse is Success) {
        SnackBarHelper.showSuccess(
          context,
          'Rol actualizado exitosamente',
          // SnackBarType.success,
        );
        Navigator.pop(context, true);
      } else if (state.updateResponse is Error) {
        final error = state.updateResponse as Error;
        SnackBarHelper.showError(
          context,
          error.message,
          // SnackBarType.error,
        );
      }
    }
  }

  bool _isLoadingState(RolState state) {
    return state.createResponse is Loading || state.updateResponse is Loading;
  }

  // === SECTIONS ===

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.blue3, size: 18,),
              const SizedBox(width: 8),
              AppTitle(
                'Información del Rol',
                // fontSize: 16,
                // color: AppColors.blue3,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nombre del rol
          CustomTextField(
            controller: _nombreController,
            borderColor: AppColors.blue3,
            label: 'Nombre del rol',
            hintText: 'Ej: Administrador, Conductor, etc.',
            prefixIcon: Icon(Icons.badge, size: 18,),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
            onChanged: (value) {
              _rolRequest = _rolRequest.copyWith(nombre: value.trim());
            },
          ),
          const SizedBox(height: 16),

          // Descripción
          CustomTextField(
            controller: _descripcionController,
            label: 'Descripción (opcional)',
            borderColor: AppColors.blue3,
            hintText: 'Describe brevemente este rol',
            // prefixIcon: Icons.description,
            prefixIcon: Icon(Icons.description, size: 18,),
            maxLines: 3,
            onChanged: (value) {
              _rolRequest = _rolRequest.copyWith(
                descripcion: value.trim().isEmpty ? null : value.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPermisosSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: AppColors.blue3, size: 20,),
                  const SizedBox(width: 8),
                  AppTitle(
                    'Permisos',
                    fontSize: 12,
                    color: AppColors.blue3,
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _selectAllPermisos,
                    icon: Icon(Icons.check_box, size: 18, color: AppColors.green),
                    label: AppTitle(
                      'Todos',
                      fontSize: 10,
                      color: AppColors.green,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _deselectAllPermisos,
                    icon: Icon(Icons.clear, size: 18, color: AppColors.red),
                    label: AppTitle(
                      'Ninguno',
                      fontSize: 10,
                      color: AppColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Secciones de permisos
          PermisosSection(
            permisos: _rolRequest.permisos,
            onPermisosChanged: (newPermisos) {
              setState(() {
                _rolRequest = _rolRequest.copyWith(permisos: newPermisos);
              });
            },
          ),
        ],
      ),
    );
  }

  // === BOTTOM BUTTON ===

  Widget _buildBottomButton(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: CustomButton(
          text: _isEditing ? 'Actualizar Rol' : 'Crear Rol',
          onPressed: isLoading ? null : _submitForm,
          enabled: !isLoading,
          buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
          // gradient: AppGradients.sinfondo,
          backgroundColor: AppColors.blue3,
          height: 35,
          borderRadius: 12,

        ),
      ),
    );
  }

  // === ACTIONS ===

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      SnackBarHelper.showWarning(
        context,
        'Por favor completa todos los campos requeridos',
        // SnackBarType.warning,
      );
      return;
    }

    // Validar que tenga al menos un permiso
    if (!_hasAnyPermiso()) {
      SnackBarHelper.showWarning(
        context,
        'Debes asignar al menos un permiso al rol',
        // SnackBarType.warning,
      );
      return;
    }

    // Actualizar nombre y descripción del request
    final finalRequest = _rolRequest.copyWith(
      nombre: _nombreController.text.trim(),
      descripcion: _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim(),
    );

    if (_isEditing) {
      context.read<RolBloc>().add(
            UpdateRolEvent(
              rolId: widget.rolToEdit!.id,
              request: finalRequest,
            ),
          );
    } else {
      context.read<RolBloc>().add(CreateRolEvent(finalRequest));
    }
  }

  bool _hasAnyPermiso() {
    final p = _rolRequest.permisos;

    // Verificar usuarios
    if (p.usuarios.crear || p.usuarios.leer || 
        p.usuarios.actualizar || p.usuarios.eliminar) {
      return true;
    }

    // Verificar unidades
    if (p.unidades.crear || p.unidades.leer || 
        p.unidades.actualizar || p.unidades.eliminar || 
        p.unidades.asignarConductor) {
      return true;
    }

    // Verificar abastecimientos
    if (p.abastecimientos.crear || p.abastecimientos.leer || 
        p.abastecimientos.actualizar || p.abastecimientos.eliminar || 
        p.abastecimientos.aprobar || p.abastecimientos.rechazar) {
      return true;
    }

    // Verificar mantenimientos
    if (p.mantenimientos.crear || p.mantenimientos.leer || 
        p.mantenimientos.actualizar || p.mantenimientos.programar) {
      return true;
    }

    // Verificar fallas
    if (p.fallas.crear || p.fallas.leer || 
        p.fallas.actualizar || p.fallas.programar) {
      return true;
    }

    // Verificar reportes
    if (p.reportes.ver || p.reportes.exportar || p.reportes.configurar) {
      return true;
    }

    // Verificar administrativo
    if (p.administrativo.configurarSistema || 
        p.administrativo.gestionarRoles || 
        p.administrativo.verAuditoria) {
      return true;
    }

    return false;
  }

  void _selectAllPermisos() {
    setState(() {
      _rolRequest = _rolRequest.copyWith(
        permisos: Permisos(
          usuarios: PermisosUsuarios(
            crear: true,
            leer: true,
            actualizar: true,
            eliminar: true,
          ),
          unidades: PermisosUnidades(
            crear: true,
            leer: true,
            actualizar: true,
            eliminar: true,
            asignarConductor: true,
          ),
          abastecimientos: PermisosAbastecimientos(
            crear: true,
            leer: true,
            actualizar: true,
            eliminar: true,
            aprobar: true,
            rechazar: true,
          ),
          mantenimientos: PermisosMantenimientos(
            crear: true,
            leer: true,
            actualizar: true,
            programar: true,
          ),
          fallas: PermisosFallas(
            crear: true,
            leer: true,
            actualizar: true,
            programar: true,
          ),
          reportes: PermisosReportes(
            ver: true,
            exportar: true,
            configurar: true,
          ),
          administrativo: PermisosAdministrativo(
            configurarSistema: true,
            gestionarRoles: true,
            verAuditoria: true,
          ),
        ),
      );
    });
  }

  void _deselectAllPermisos() {
    setState(() {
      _rolRequest = CreateRolRequest.empty(
        nombre: _nombreController.text,
        descripcion: _descripcionController.text.isEmpty 
            ? null 
            : _descripcionController.text,
      );
    });
  }
}
// lib/presentation/page/user/widgets/assign_rol_dialog.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/avatar_circle.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_dropdown.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/loadings/custom_loading.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_bloc.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_event.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_state.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';
import 'package:consumo_combustible/presentation/page/user/widgets/user_role_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssignRolDialog extends StatefulWidget {
  final User user;

  const AssignRolDialog({super.key, required this.user});

  @override
  State<AssignRolDialog> createState() => _AssignRolDialogState();
}

class _AssignRolDialogState extends State<AssignRolDialog> {
  int? _selectedRolId;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // Cargar roles disponibles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolBloc>().add(const GetRolesEvent(page: 1, limit: 100));
    });
  }

  Future<void> _loadCurrentUser() async {
    final authUseCases = locator<AuthUseCases>();
    final session = await authUseCases.getUserSession.run();
    if (session?.data?.user != null) {
      setState(() => _currentUserId = session!.data!.user.id);
    }
  }

  void _assignRol() {
    if (_selectedRolId == null) {
      SnackBarHelper.showError(context, 'Por favor selecciona un rol');
      return;
    }

    if (_currentUserId == null) {
      SnackBarHelper.showError(
        context,
        'Error: No se pudo obtener el usuario actual',
      );
      return;
    }

    // Disparar evento para asignar rol
    context.read<UserBloc>().add(
      AssignRolToUser(
        userId: widget.user.id,
        rolId: _selectedRolId!,
        asignadoPorId: _currentUserId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserRolAssignSuccess) {
          SnackBarHelper.showSuccess(context, state.message);
          Navigator.of(context).pop(true); // Cerrar dialog con éxito
        } else if (state is UserRolAssignError) {
          SnackBarHelper.showError(context, state.message);
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfo(),
                      const SizedBox(height: 24),
                      _buildRolDropdown(),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.blue3,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: AppTitle('Asignar Rol', color: AppColors.white),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final nombreCompleto = '${widget.user.nombres} ${widget.user.apellidos}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue3.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue3.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarCircle(
                colors: [AppColors.orange,AppColors.orange, ],
                text: nombreCompleto
                    .split(' ')
                    .map((n) => n[0])
                    .take(2)
                    .join()
                    .toUpperCase(),
                size: 25,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSubtitle(
                      nombreCompleto,
                      fontSize: 10,
                      color: AppColors.blue3,
                    ),
                    const SizedBox(height: 4),
                    AppCaption(
                      font: AppFont.oxygenBold,
                      items: [
                        CaptionItem(
                          icon: Icons.badge_outlined,
                          text: widget.user.dni,                          
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          AppSubtitle('Roles Asignado:'),
          //! Mostrar roles actuales
          if (widget.user.hasRoles) ...[
            const SizedBox(height: 5),
            UserRoleChips(user: widget.user),
          ],
        ],
      ),
    );
  }

  Widget _buildRolDropdown() {
    return BlocBuilder<RolBloc, RolState>(
      builder: (context, state) {
        if (state.rolesResponse is Loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: CustomLoading(message: 'Cargando roles...'),
            ),
          );
        }

        if (state.roles.isEmpty) {
          return Center(
            child: AppSubtitle(
              'No hay roles disponibles',
              color: Colors.grey[600],
            ),
          );
        }

        // Filtrar roles que el usuario ya tiene
        final availableRoles = state.roles.where((rol) {
          if (!widget.user.hasRoles) return true;
          return !widget.user.rolesAsList.any(
            (userRol) => userRol.id == rol.id,
          );
        }).toList();

        if (availableRoles.isEmpty) {
          return Center(
            child: AppSubtitle(
              'El usuario ya tiene todos los roles disponibles',
              color: Colors.grey[600],
            ),
          );
        }

        return CustomDropdown(
          label: 'Seleccionar Rol *',
          hintText: 'Elegir un rol para asignar',
          items: availableRoles.map((rol) {
            return DropdownItem(value: rol.id.toString(), label: rol.nombre);
          }).toList(),
          value: _selectedRolId?.toString(),
          borderColor: AppColors.blue3,
          onChanged: (value) {
            setState(() {
              _selectedRolId = value != null ? int.parse(value) : null;
            });
          },
        );
      },
    );
  }

  Widget _buildActions() {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final isLoading = state is UserRolAssigning;

        return Row(
          children: [
            Expanded(
              child: CustomButton(
                height: 35,
                text: 'Cancelar',
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                backgroundColor: Colors.grey[300],
                textColor: Colors.grey[700],
                enabled: !isLoading,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                height: 35,
                text: 'Asignar Rol',
                onPressed: isLoading ? null : _assignRol,
                buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
                loadingText: 'Asignando...',
                backgroundColor: AppColors.blue3,
                fontSize: 10,
              ),
            ),
          ],
        );
      },
    );
  }
}

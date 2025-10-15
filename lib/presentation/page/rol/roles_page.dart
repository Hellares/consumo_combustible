// lib/presentation/page/roles/roles_page.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_bloc.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_event.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_state.dart';
import 'package:consumo_combustible/presentation/page/rol/create_rol_page.dart';
import 'package:consumo_combustible/presentation/page/rol/widgets/rol_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Cargar roles después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RolBloc>().add(const GetRolesEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Detectar scroll para paginación infinita
  void _onScroll() {
    if (_isBottom && !_isLoadingMore) {
      final state = context.read<RolBloc>().state;
      if (state.hasMorePages) {
        context.read<RolBloc>().add(
          GetRolesEvent(
            page: state.currentPage + 1,
            isLoadMore: true,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  bool get _isLoadingMore {
    return context.read<RolBloc>().state.isLoadingMore;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SmartAppBar.withUser(
        title: 'Gestión de Roles',
        showLogo: true,
        logoPath: ApiConfig.logoPath,
      ),
      body: GradientContainer(
        gradient: AppGradients.sinfondo,
        child: BlocConsumer<RolBloc, RolState>(
          listener: _handleBlocListener,
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context, state),
                _buildContent(context, state),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // === LISTENERS ===

  void _handleBlocListener(BuildContext context, RolState state) {
    // Manejo de respuesta de eliminación
    if (state.deleteResponse != null) {
      if (state.deleteResponse is Success) {
        SnackBarHelper.showSuccess(
          context,
          'Rol eliminado exitosamente',
          // SnackBarType.success,
        );
        context.read<RolBloc>().add(const ResetRolStateEvent());
      } else if (state.deleteResponse is Error) {
        final error = state.deleteResponse as Error;
        SnackBarHelper.showError(
          context,
          error.message,
          // SnackBarType.error,
        );
        context.read<RolBloc>().add(const ResetRolStateEvent());
      }
    }

    // Manejo de respuesta de activación
    if (state.activarResponse != null) {
      if (state.activarResponse is Success) {
        SnackBarHelper.showSuccess(
          context,
          'Rol activado exitosamente',
          // SnackBarType.success,
        );
        context.read<RolBloc>().add(const ResetRolStateEvent());
      } else if (state.activarResponse is Error) {
        final error = state.activarResponse as Error;
        SnackBarHelper.showError(
          context,
          error.message,
          // SnackBarType.error,
        );
        context.read<RolBloc>().add(const ResetRolStateEvent());
      }
    }
  }

  // === HEADER ===

  Widget _buildHeader(BuildContext context, RolState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y contador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppTitle(
                'Roles del Sistema',
                // fontSize: 12,
                // color: AppColors.blue3,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.blue3.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: AppSubtitle(
                  '${state.totalRoles} roles',
                  fontSize: 9,
                  // color: AppColors.blue3,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 16),

          // Barra de búsqueda (preparada para futuro)
          // _buildSearchBar(),
        ],
      ),
    );
  }

  // Widget _buildSearchBar() {
  //   return TextField(
  //     controller: _searchController,
  //     decoration: InputDecoration(
  //       hintText: 'Buscar roles...',
  //       prefixIcon: Icon(Icons.search, color: AppColors.blue3),
  //       suffixIcon: _searchController.text.isNotEmpty
  //           ? IconButton(
  //               icon: Icon(Icons.clear, color: AppColors.blue3),
  //               onPressed: () {
  //                 _searchController.clear();
  //                 setState(() {});
  //                 // TODO: Implementar búsqueda cuando esté disponible en el backend
  //               },
  //             )
  //           : null,
  //       filled: true,
  //       fillColor: Colors.white,
  //       border: OutlineInputBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         borderSide: BorderSide.none,
  //       ),
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 16,
  //         vertical: 12,
  //       ),
  //     ),
  //     onChanged: (value) {
  //       setState(() {});
  //       // TODO: Implementar búsqueda con debounce
  //     },
  //   );
  // }

  // === CONTENT ===

  Widget _buildContent(BuildContext context, RolState state) {
    final response = state.rolesResponse;

    // Loading inicial
    if (response is Loading && state.roles.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.blue3),
              const SizedBox(height: 16),
              AppTitle(
                'Cargando roles...',
                fontSize: 14,
                color: AppColors.blue3,
              ),
            ],
          ),
        ),
      );
    }

    // Error inicial
    if (response is Error && state.roles.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.red,
              ),
              const SizedBox(height: 16),
              AppTitle(
                (response as Error?)?.message ?? 'Error desconocido',                
                fontSize: 14,
                color: AppColors.red,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<RolBloc>().add(const GetRolesEvent());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue3,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Lista vacía
    if (state.roles.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 64,
                color: AppColors.blue3.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              AppTitle(
                'No hay roles registrados',
                fontSize: 14,
                color: AppColors.blue3,
              ),
              const SizedBox(height: 8),
              AppTitle(
                'Presiona + para crear el primer rol',
                fontSize: 12,
                color: AppColors.blue3.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      );
    }

    // Lista de roles
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<RolBloc>().add(const GetRolesEvent());
        },
        color: AppColors.blue3,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.roles.length + (state.hasMorePages ? 1 : 0),
          itemBuilder: (context, index) {
            // Mostrar loading indicator al final
            if (index >= state.roles.length) {
              return _buildLoadingMoreIndicator();
            }

            final rol = state.roles[index];
            return RolCard(
              rol: rol,
              onTap: () => _navigateToEditRol(context, rol),
              onDelete: () => _confirmDeleteRol(context, rol),
              onActivar: () => _confirmActivarRol(context, rol),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: AppColors.blue3,
        strokeWidth: 2,
      ),
    );
  }

  // === FLOATING ACTION BUTTON ===

  Widget _buildFloatingActionButton(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 120,
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateRol(context),
        backgroundColor: AppColors.blue3,
        icon: const Icon(Icons.add, color: Colors.white, size: 16,),
        label: AppTitle(
          'Nuevo Rol',
          fontSize: 9,
          color: Colors.white,
          font: AppFont.pirulentBold,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(8)),
      ),
      
    );
  }

  // === NAVIGATION ===

  void _navigateToCreateRol(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateRolPage(),
      ),
    );

    // Si se creó un rol, recargar la lista
    if (result == true && mounted) {
      context.read<RolBloc>().add(const GetRolesEvent());
    }
  }

  void _navigateToEditRol(BuildContext context, Rol rol) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRolPage(rolToEdit: rol),
      ),
    );

    // Si se editó un rol, la lista ya se actualiza automáticamente por el BLoC
    if (result == true && mounted) {
      // Opcional: puedes mostrar un mensaje o hacer scroll al inicio
    }
  }

  // === ACTIONS ===

  void _confirmDeleteRol(BuildContext context, Rol rol) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppTitle(
          'Eliminar Rol',
          fontSize: 18,
          color: AppColors.blue3,
        ),
        content: AppTitle(
          '¿Estás seguro de que deseas eliminar el rol "${rol.nombre}"?\n\n'
          'Esta acción desactivará el rol y no podrá ser asignado a nuevos usuarios.',
          fontSize: 14,
          color: AppColors.blue3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppTitle(
              'Cancelar',
              fontSize: 14,
              color: AppColors.blue3,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RolBloc>().add(DeleteRolEvent(rol.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: AppTitle(
              'Eliminar',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmActivarRol(BuildContext context, Rol rol) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: AppTitle(
          'Activar Rol',
          fontSize: 18,
          color: AppColors.blue3,
        ),
        content: AppTitle(
          '¿Deseas activar el rol "${rol.nombre}"?\n\n'
          'El rol podrá ser asignado a usuarios nuevamente.',
          fontSize: 14,
          color: AppColors.blue3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppTitle(
              'Cancelar',
              fontSize: 14,
              color: AppColors.blue3,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RolBloc>().add(ActivarRolEvent(rol.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            child: AppTitle(
              'Activar',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
// lib/presentation/page/role_selection/role_selection_page.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/roles.dart';
import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> 
    with SingleTickerProviderStateMixin {
  
  Role? _selectedRole;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final _authUseCases = locator<AuthUseCases>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _transparentBar();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  void _transparentBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtener usuario de los argumentos
    final user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientContainer(
        gradient: AppGradients.custom(
          startColor: AppColors.white,
          middleColor: AppColors.white,
          endColor: const Color.fromARGB(255, 175, 213, 250),
          stops: [0.0, 0.5, 1.0],
        ),
        height: double.infinity,
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 40),
                  _buildInstructions(),
                  const SizedBox(height: 30),
                  Expanded(
                    child: _buildRolesList(user.roles),
                  ),
                  const SizedBox(height: 20),
                  _buildContinueButton(user),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, ${user.nombres}',
          style: AppFont.oxygenBold.style(
            fontSize: 18,
            color: AppColors.blue3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona tu rol',
          style: AppFont.orbitronMedium.style(
            fontSize: 16,
            color: AppColors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue3.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue3.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.blue3, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tienes múltiples roles asignados. Selecciona el rol con el que deseas trabajar.',
              style: AppFont.oxygenBold.style(
                fontSize: 12,
                color: AppColors.blue3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolesList(List<Role> roles) {
    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        final isSelected = _selectedRole?.rol.id == role.rol.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _selectRole(role),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.blue 
                        : AppColors.grey.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.blue.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.blue 
                            : AppColors.grey.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRoleIcon(role.rol.nombre),
                        color: isSelected ? Colors.white : AppColors.blue2,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.rol.nombre,
                            style: AppFont.oxygenBold.style(
                              fontSize: 16,
                              color: AppColors.blue2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role.rol.descripcion,
                            style: AppFont.oxygenRegular.style(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: AppColors.blue,
                        size: 28,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContinueButton(User user) {
    return CustomButton(
      text: _isLoading ? 'Guardando...' : 'Continuar',
      backgroundColor: AppColors.blue3,
      textColor: AppColors.white,
      borderRadius: 28,
      textStyle: AppFont.pirulentBold.style(fontSize: 14),
      onPressed: _selectedRole != null && !_isLoading
          ? () => _confirmRoleSelection(user)
          : null,
    );
  }

  IconData _getRoleIcon(String roleName) {
    final name = roleName.toLowerCase();
    if (name.contains('admin')) return Icons.admin_panel_settings;
    if (name.contains('conductor')) return Icons.local_shipping;
    if (name.contains('operador')) return Icons.build;
    if (name.contains('supervisor')) return Icons.supervisor_account;
    return Icons.person;
  }

  void _selectRole(Role role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _confirmRoleSelection(User user) async {
    if (_selectedRole == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Crear rol seleccionado
      final selectedRole = SelectedRole(
        userId: user.id,
        role: _selectedRole!,
        selectedAt: DateTime.now(),
      );

      // Guardar rol
      await _authUseCases.saveSelectedRole.run(selectedRole);

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Rol ${_selectedRole!.rol.nombre} seleccionado',
        );

        // Capturar navigator antes del async gap
        final navigator = Navigator.of(context);

        // Navegar a home
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            navigator.pushNamedAndRemoveUntil(
              'home',
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackBarHelper.showError(context, 'Error al guardar rol');
      }
    }
  }
}
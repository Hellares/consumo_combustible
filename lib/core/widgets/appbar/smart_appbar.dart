// lib/core/widgets/appbar/smart_appbar.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

/// 🚀 SmartAppBar - AppBar inteligente todo-en-uno
/// 
/// Modos de uso:
/// 1. Con usuario automático (carga desde storage y mantiene cache interno)
/// 2. Con usuario manual (pasas los datos)
/// 3. Sin usuario (AppBar básico)
/// 4. Personalizado (widgets custom en leading)
class SmartAppBar extends StatefulWidget implements PreferredSizeWidget {
  // === PROPIEDADES BÁSICAS ===
  final String? title;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final double elevation;
  final bool centerTitle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  // === LOGO ===
  final bool showLogo;
  final String? logoPath;
  final double logoSize;
  final bool isLottieLogo;

  // === USUARIO (MODO AUTOMÁTICO) ===
  final bool showUserInfo;
  final VoidCallback? onUserInfoTap;
  final TextStyle? userInfoStyle;

  // === USUARIO (MODO MANUAL) ===
  final String? manualUserRole;
  final String? manualUserName;

  // === LEADING PERSONALIZADO ===
  final Widget? leftWidget;
  final IconData? leftIcon;
  final String? leftIconPath;
  final VoidCallback? onLeftTap;
  final Color? iconColor;

  const SmartAppBar({
    super.key,
    // Básicas
    this.title,
    this.titleStyle,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0,
    this.centerTitle = true,
    this.systemOverlayStyle,
    // Logo
    this.showLogo = true,
    this.logoPath = 'assets/animations/logo1.json',
    this.logoSize = 27,
    this.isLottieLogo = true,
    // Usuario automático
    this.showUserInfo = false,
    this.onUserInfoTap,
    this.userInfoStyle,
    // Usuario manual
    this.manualUserRole,
    this.manualUserName,
    // Leading personalizado
    this.leftWidget,
    this.leftIcon,
    this.leftIconPath,
    this.onLeftTap,
    this.iconColor,
  });

  // === FACTORY CONSTRUCTORS ===

  /// AppBar básico sin usuario
  factory SmartAppBar.basic({
    String? title,
    bool showLogo = true,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      showUserInfo: false,
    );
  }

  /// AppBar con usuario automático (carga desde storage)
  factory SmartAppBar.withUser({
    String? title,
    bool showLogo = true,
    VoidCallback? onUserTap,
    String? logoPath,
    bool isLottieLogo = true,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      showUserInfo: true,
      onUserInfoTap: onUserTap,
      logoPath: logoPath,
      isLottieLogo: isLottieLogo,
    );
  }

  /// AppBar con usuario manual
  factory SmartAppBar.withManualUser({
    required String role,
    required String name,
    String? title,
    bool showLogo = true,
    VoidCallback? onUserTap,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      manualUserRole: role,
      manualUserName: name,
      onUserInfoTap: onUserTap,
    );
  }

  /// AppBar con botón de regreso
  factory SmartAppBar.withBackButton({
    String? title,
    VoidCallback? onBack,
    bool showLogo = true,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      leftIcon: Icons.arrow_back_ios,
      onLeftTap: onBack,
    );
  }

  /// AppBar con leading personalizado
  factory SmartAppBar.custom({
    String? title,
    Widget? leftWidget,
    IconData? leftIcon,
    VoidCallback? onLeftTap,
    bool showLogo = true,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      leftWidget: leftWidget,
      leftIcon: leftIcon,
      onLeftTap: onLeftTap,
    );
  }

  @override
  State<SmartAppBar> createState() => _SmartAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SmartAppBarState extends State<SmartAppBar> {
  // Cache interno para datos del usuario
  Map<String, String>? _cachedUserInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Solo cargar si showUserInfo es true
    if (widget.showUserInfo) {
      _loadUserInfo();
    }
  }

  Future<void> _loadUserInfo() async {
    // Si ya está cargado, no volver a cargar
    if (_cachedUserInfo != null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authUseCases = locator<AuthUseCases>();
      final userSession = await authUseCases.getUserSession.run();
      final selectedRole = await authUseCases.getSelectedRole.run();
      
      if (userSession != null && selectedRole != null) {
        final user = userSession.data?.user;
        
        if (mounted) {
          setState(() {
            _cachedUserInfo = {
              'role': selectedRole.role.rol.nombre,
              'name': '${user?.nombres ?? ''} ${user?.apellidos ?? ''}'.trim(),
              'email': user?.email ?? '',
            };
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: widget.backgroundColor,
      elevation: widget.elevation,
      centerTitle: widget.centerTitle,
      automaticallyImplyLeading: false,
      systemOverlayStyle: widget.systemOverlayStyle ?? _defaultSystemOverlayStyle,
      title: _buildTitle(),
      leading: _buildLeading(context),
      leadingWidth: _getLeadingWidth(),
      actions: widget.showLogo ? [_buildLogo()] : null,
      iconTheme: IconThemeData(
        color: widget.iconColor ?? AppColors.blue3,
      ),
    );
  }

  // === BUILDERS ===

  Widget? _buildTitle() {
    if (widget.title == null) return null;
    
    return Text(
      widget.title!,
      style: widget.titleStyle ?? AppFont.pirulentBold.style(
        fontSize: 11,
        color: AppColors.blue3,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    // 1. Usuario manual tiene prioridad
    if (widget.manualUserRole != null || widget.manualUserName != null) {
      return _buildUserInfoWidget(
        role: widget.manualUserRole ?? '',
        name: widget.manualUserName ?? '',
        context: context,
      );
    }

    // 2. Usuario automático con cache
    if (widget.showUserInfo) {
      if (_isLoading) {
        return _buildLoadingUserInfo();
      }
      
      if (_cachedUserInfo != null && _cachedUserInfo!.isNotEmpty) {
        return _buildUserInfoWidget(
          role: _cachedUserInfo!['role'] ?? '',
          name: _cachedUserInfo!['name'] ?? '',
          context: context,
          userData: _cachedUserInfo,
        );
      }
      
      return const SizedBox.shrink();
    }

    // 3. Leading personalizado
    if (widget.leftWidget != null) {
      return GestureDetector(
        onTap: widget.onLeftTap,
        child: widget.leftWidget!,
      );
    }

    // 4. Icono personalizado
    if (widget.leftIcon != null) {
      return IconButton(
        icon: Icon(widget.leftIcon!, color: widget.iconColor ?? AppColors.blue3),
        onPressed: widget.onLeftTap,
      );
    }

    // 5. Path de imagen
    if (widget.leftIconPath != null) {
      return GestureDetector(
        onTap: widget.onLeftTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: Image.asset(
            widget.leftIconPath!,
            width: 20,
            height: 20,
            color: widget.iconColor ?? AppColors.blue3,
          ),
        ),
      );
    }

    // 6. Botón de regreso por defecto
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: widget.iconColor ?? AppColors.blue3,
          size: 20,
        ),
        onPressed: widget.onLeftTap ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  /// Widget de información del usuario
  Widget _buildUserInfoWidget({
    required String role,
    required String name,
    required BuildContext context,
    Map<String, String>? userData,
  }) {
    return GestureDetector(
      onTap: () {
        if (widget.onUserInfoTap != null) {
          widget.onUserInfoTap!();
        } else if (userData != null) {
          _showUserMenu(context, userData);
        }
      },
      child: Container(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.blue3.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.blue3.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person,
                size: 18,
                color: AppColors.blue2,
              ),
            ),
            const SizedBox(width: 8),
            // Rol y Nombre
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role.isNotEmpty)
                    Text(
                      role,
                      style: widget.userInfoStyle ?? AppFont.oxygenBold.style(
                        fontSize: 11,
                        color: AppColors.blue3,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: AppFont.oxygenRegular.style(
                        fontSize: 9,
                        color: AppColors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUserInfo() {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 40,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
  if (widget.logoPath == null) return const SizedBox.shrink();

  final path = widget.logoPath!;
  final size = widget.logoSize;

  Widget logoWidget;

  if (path.endsWith('.json')) {
    // Lottie
    logoWidget = Lottie.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  } else if (path.endsWith('.svg')) {
    // SVG
    logoWidget = SvgPicture.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  } else {
    // Imagen normal (png, jpg, etc.)
    logoWidget = Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }

  return Container(
    margin: const EdgeInsets.only(right: 20),
    child: Center(child: logoWidget),
  );
}

  // === HELPERS ===

  double? _getLeadingWidth() {
    if (widget.showUserInfo || widget.manualUserRole != null || widget.manualUserName != null) {
      return 200;
    }
    return null;
  }

  SystemUiOverlayStyle get _defaultSystemOverlayStyle {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  // === USER MENU ===

  void _showUserMenu(BuildContext context, Map<String, String> userData) async {
    final authUseCases = locator<AuthUseCases>();
    final userSession = await authUseCases.getUserSession.run();
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.blue3.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, size: 30, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData['email'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(userData['role'] ?? ''),
                        backgroundColor: AppColors.blue3.withValues(alpha: 0.1),
                        padding: EdgeInsets.zero,
                        labelStyle: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            
            // Cambiar Rol
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.blue),
              title: const Text('Cambiar Rol'),
              onTap: () {
                Navigator.pop(modalContext);
                
                if (userSession?.data?.user != null) {
                  Navigator.pushNamed(
                    context,
                    'role-selection',
                    arguments: userSession!.data!.user,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Sesión no encontrada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.person_outline, color: Colors.blue),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Implementar
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: Colors.blue),
              title: const Text('Configuración'),
              onTap: () {
                Navigator.pop(modalContext);
                // TODO: Implementar
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(modalContext);
                _handleLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamedAndRemoveUntil(
                context,
                'login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
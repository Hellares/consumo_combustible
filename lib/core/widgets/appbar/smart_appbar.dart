
// lib/core/widgets/appbar/smart_appbar.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/logout/logout_button.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/user/widgets/user_role_chips.dart';
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
/// 5. Logout integrado en menú de usuario
class SmartAppBar extends StatefulWidget implements PreferredSizeWidget {
  // === PROPIEDADES BÁSICAS ===
  final String? title;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final double elevation;
  final bool centerTitle;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final double? customHeight;  // Nueva propiedad para altura personalizada

  // === LOGO ===
  final bool showLogo;
  final String? logoPath;
  final double logoSize;

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
    this.customHeight,  // Por defecto null (usa kToolbarHeight)
    // Logo
    this.showLogo = true,
    this.logoPath,
    this.logoSize = 21,
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
    double? customHeight,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      showUserInfo: false,
      customHeight: customHeight,
    );
  }

  /// AppBar con usuario automático (carga desde storage)
  factory SmartAppBar.withUser({
    String? title,
    bool showLogo = true,
    VoidCallback? onUserTap,
    String? logoPath,
    double? customHeight,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      showUserInfo: true,
      onUserInfoTap: onUserTap,
      logoPath: logoPath ?? ApiConfig.logoLottiePath,
      customHeight: customHeight,
    );
  }

  /// AppBar con usuario manual
  factory SmartAppBar.withManualUser({
    required String role,
    required String name,
    String? title,
    bool showLogo = true,
    VoidCallback? onUserTap,
    double? customHeight,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      manualUserRole: role,
      manualUserName: name,
      onUserInfoTap: onUserTap,
      customHeight: customHeight,
    );
  }

  /// AppBar con botón de regreso
  factory SmartAppBar.withBackButton({
    String? title,
    VoidCallback? onBack,
    bool showLogo = true,
    double? customHeight,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      leftIcon: Icons.arrow_back_ios,
      onLeftTap: onBack,
      customHeight: customHeight,
    );
  }

  /// AppBar con leading personalizado
  factory SmartAppBar.custom({
    String? title,
    Widget? leftWidget,
    IconData? leftIcon,
    VoidCallback? onLeftTap,
    bool showLogo = true,
    double? customHeight,
  }) {
    return SmartAppBar(
      title: title,
      showLogo: showLogo,
      leftWidget: leftWidget,
      leftIcon: leftIcon,
      onLeftTap: onLeftTap,
      customHeight: customHeight,
    );
  }

  @override
  State<SmartAppBar> createState() => _SmartAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(customHeight ?? kToolbarHeight);
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
      systemOverlayStyle:
          widget.systemOverlayStyle ?? _defaultSystemOverlayStyle,
      title: _buildTitle(),
      leading: _buildLeading(context),
      leadingWidth: _getLeadingWidth(),
      actions: widget.showLogo ? [_buildLogo()] : null,
      iconTheme: IconThemeData(color: widget.iconColor ?? AppColors.blue3),
      toolbarHeight: widget.customHeight ?? kToolbarHeight,  // Aplica la altura personalizada
      surfaceTintColor: Colors.transparent,  // AGREGADO: Desactiva el tintado en Material 3 durante scroll (evita el morado claro)
    );
  }

  // === BUILDERS ===

  Widget? _buildTitle() {
    if (widget.title == null) return null;

    return Text(
      widget.title!,
      style:
          widget.titleStyle ??
          AppFont.pirulentBold.style(fontSize: 8, color: AppColors.blue3),
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
        icon: Icon(
          widget.leftIcon!,
          color: widget.iconColor ?? AppColors.blue3,
        ),
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
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.blue3.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.blue3.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Icon(Icons.person, size: 12, color: AppColors.blue2),
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
                      style:
                          widget.userInfoStyle ??
                          AppFont.oxygenBold.style(
                            fontSize: 8,
                            color: AppColors.blue3,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (name.isNotEmpty)
                    Text(
                      name,
                      style: AppFont.oxygenRegular.style(
                        fontSize: 7,
                        color: AppColors.blueGrey,
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
    if (widget.showUserInfo ||
        widget.manualUserRole != null ||
        widget.manualUserName != null) {
      return 200;
    }
    return null;
  }

  SystemUiOverlayStyle get _defaultSystemOverlayStyle {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    );
  }

  // === MENÚ DE USUARIO CON LOGOUT INTEGRADO ===

  void _showUserMenu(BuildContext context, Map<String, String> userData) async {
    final authUseCases = locator<AuthUseCases>();
    final userSession = await authUseCases.getUserSession.run();

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,  // ✅ Mantiene el scroll controlado para altura mínima
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),  // ✅ Reducido de 20 a 16 para más compacto
      ),
      builder: (modalContext) => ConstrainedBox(  // ✅ NUEVO: Limita la altura máxima al 40% de la pantalla
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // ✅ Reducido de 16 a 12 para menos padding
          child: SingleChildScrollView(  // ✅ AGREGADO: Permite scroll si el contenido excede la altura máxima
            physics: const ClampingScrollPhysics(),  // ✅ Scroll suave sin rebote
            child: Column(
              mainAxisSize: MainAxisSize.min,  // ✅ Mantiene el tamaño mínimo
              children: [
                // Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,  // ✅ Reducido de 23 a 20
                      backgroundColor: AppColors.blue3.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, size: 18, color: AppColors.blue1),  // ✅ Icono más pequeño
                    ),
                    const SizedBox(width: 12),  // ✅ Reducido de 16 a 12
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,  // ✅ Reducido de 12 a 11
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),  // ✅ Reducido de 4 a 2
                          Text(
                            userData['email'] ?? '',
                            style: TextStyle(fontSize: 9, color: Colors.grey[600]),  // ✅ Reducido de 10 a 9
                          ),
                          const SizedBox(height: 5),

                          UserRoleChips(user: userSession!.data!.user! ),  // !Reemplazado por UserRoleChips para mejor estilo
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),  // ✅ Reducido de 10 a 8
                const Divider(),
                const SizedBox(height: 5),  // ✅ Reducido de 10 a 8

                // ✅ NUEVO: Theme wrapper para ListTiles compactos (reduce altura entre opciones)
                Theme(
                  data: Theme.of(context).copyWith(
                    listTileTheme: ListTileThemeData(
                      visualDensity: VisualDensity.compact,  // ✅ Reduce altura de ListTiles ~20-30%
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),  // ✅ Elimina vertical padding extra
                      dense: true,  // ✅ Modo dense para más compacidad
                    ),
                  ),
                  child: Column(
                    children: [
                      // Cambiar Rol
                      ListTile(
                        leading: const Icon(Icons.swap_horiz, size: 18, color: Colors.blue),  // ✅ Icono más pequeño
                        title: const Text('Cambiar Rol', style: TextStyle(fontSize: 12)),  // ✅ Fuente más pequeña
                        onTap: () {
                          Navigator.pop(modalContext);

                          if (userSession.data?.user != null) {
                            Navigator.pushNamed(
                              context,
                              'role-selection',
                              arguments: userSession.data!.user,
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

                      // Mi Perfil
                      ListTile(
                        leading: const Icon(Icons.person_outline, size: 18, color: Colors.blue),  // ✅ Icono más pequeño
                        title: const Text('Mi Perfil', style: TextStyle(fontSize: 12)),  // ✅ Fuente más pequeña
                        onTap: () {
                          Navigator.pop(modalContext);
                          // TODO: Implementar
                        },
                      ),

                      // Configuración
                      ListTile(
                        leading: const Icon(Icons.settings_outlined, size: 18, color: Colors.blue),  // ✅ Icono más pequeño
                        title: const Text('Configuración', style: TextStyle(fontSize: 12)),  // ✅ Fuente más pequeña
                        onTap: () {
                          Navigator.pop(modalContext);
                          // TODO: Implementar
                        },
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Logout (fuera del Theme para mantener su estilo si es necesario)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),  // ✅ Padding más compacto
                  title: LogoutButton.profile(
                    text: 'Cerrar Sesión',
                    onLogoutSuccess: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        'login',
                        (route) => false,
                      );
                    },
                    // onLogoutSuccess: (){},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
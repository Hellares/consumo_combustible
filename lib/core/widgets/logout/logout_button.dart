import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


enum LogoutButtonStyle {
  iconOnly,
  textOnly,
  iconWithText,
}

class LogoutButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final LogoutButtonStyle style;
  final VoidCallback? onPressed;
  final VoidCallback? onLogoutSuccess;
  final VoidCallback? onLogoutError;
  final bool showConfirmDialog;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool? showIconOnly;
  final bool logoutAll; // ✅ NUEVO: Para cerrar todas las sesiones

  const LogoutButton({
    super.key,
    this.text,
    this.icon,
    this.style = LogoutButtonStyle.iconWithText,
    this.onPressed,
    this.onLogoutSuccess,
    this.onLogoutError,
    this.showConfirmDialog = true,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.padding,
    this.borderRadius,
    this.showIconOnly,
    this.logoutAll = false, // ✅ Por defecto logout normal
  });

  // Factory para botón de AppBar
  factory LogoutButton.appBar({
    IconData? icon = Icons.logout,
    VoidCallback? onLogoutSuccess,
    bool showConfirmDialog = true,
  }) {
    return LogoutButton(
      style: LogoutButtonStyle.iconOnly,
      icon: icon,
      onLogoutSuccess: onLogoutSuccess,
      showConfirmDialog: showConfirmDialog,
      iconColor: AppColors.blue2,
    );
  }

  // Factory para menú lateral
  factory LogoutButton.drawer({
    String? text = 'Cerrar Sesión',
    IconData? icon = Icons.logout,
    VoidCallback? onLogoutSuccess,
  }) {
    return LogoutButton(
      style: LogoutButtonStyle.iconWithText,
      text: text,
      icon: icon,
      onLogoutSuccess: onLogoutSuccess,
      backgroundColor: Colors.transparent,
      textColor: Colors.red,
      iconColor: Colors.red,
    );
  }

  // Factory para página de perfil
  factory LogoutButton.profile({
    String? text = 'Cerrar Sesión',
    VoidCallback? onLogoutSuccess,
    bool logoutAll = false,
  }) {
    return LogoutButton(
      style: LogoutButtonStyle.textOnly,
      text: text,
      onLogoutSuccess: onLogoutSuccess,
      backgroundColor: AppColors.blue3,
      textColor: Colors.white,
      borderRadius: 28,
      fontSize: 10,
      logoutAll: logoutAll,
    );
  }

  // ✅ NUEVO: Factory para cerrar todas las sesiones
  factory LogoutButton.logoutAll({
    String? text = 'Cerrar Todas las Sesiones',
    IconData? icon = Icons.logout_outlined,
    VoidCallback? onLogoutSuccess,
    LogoutButtonStyle style = LogoutButtonStyle.iconWithText,
  }) {
    return LogoutButton(
      style: style,
      text: text,
      icon: icon,
      onLogoutSuccess: onLogoutSuccess,
      backgroundColor: Colors.red.shade50,
      textColor: Colors.red.shade700,
      iconColor: Colors.red.shade700,
      fontSize: 8,
      logoutAll: true, // ✅ Activar logout de todas las sesiones
      showConfirmDialog: true,
    );
  }

  factory LogoutButton.iconOnly({
  IconData icon = Icons.logout,
  Color? color,
  VoidCallback? onLogoutSuccess,
}) {
  return LogoutButton(
    icon: icon,
    backgroundColor: Colors.transparent,
    iconColor: color ?? Colors.red,
    showConfirmDialog: true,
    showIconOnly: true, // Solo icono, sin texto
    onLogoutSuccess: onLogoutSuccess,
  );
}

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listener: (context, state) {
        final responseState = state.response;
        
        // Manejar resultado del logout
        if (responseState is Success && responseState.data is String) {
          // Logout exitoso
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              SnackBarHelper.showSuccess(context, 'Sesión cerrada exitosamente');
              
              // Callback personalizado o navegación por defecto
              if (onLogoutSuccess != null) {
                onLogoutSuccess!();
              } else {
                _navigateToLogin(context);
              }
            }
          });
          
        } else if (responseState is Error) {
          // Error en logout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              SnackBarHelper.showError(context, 'Error al cerrar sesión: ${responseState.message}');
              
              if (onLogoutError != null) {
                onLogoutError!();
              }
            }
          });
        }
      },
      builder: (context, state) {
        final isLoading = state.response is Loading;
        final canLogout = context.read<LoginBloc>().canLogout;

        return _buildButton(context, isLoading, canLogout);
      },
    );
  }

  Widget _buildButton(BuildContext context, bool isLoading, bool canLogout) {
    switch (style) {
      case LogoutButtonStyle.iconOnly:
        return _buildIconButton(context, isLoading, canLogout);
      
      case LogoutButtonStyle.textOnly:
        return _buildTextButton(context, isLoading, canLogout);
      
      case LogoutButtonStyle.iconWithText:
        return _buildIconWithTextButton(context, isLoading, canLogout);
    }
  }

  Widget _buildIconButton(BuildContext context, bool isLoading, bool canLogout) {
    return IconButton(
      onPressed: canLogout && !isLoading ? () => _handleLogout(context) : null,
      icon: isLoading 
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(iconColor ?? Colors.grey),
            ),
          )
        : Icon(
            icon ?? Icons.logout,
            color: iconColor ?? AppColors.red,
          ),
      tooltip: 'Cerrar Sesión',
    );
  }

  Widget _buildTextButton(BuildContext context, bool isLoading, bool canLogout) {
    return CustomButton(
      text: text ?? 'Cerrar Sesión',
      loadingText: 'Cerrando...',
      buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
      textStyle: AppFont.pirulentBold.style(
        fontSize: fontSize ?? 12,
        color: textColor ?? Colors.white,
      ),
      backgroundColor: backgroundColor ?? AppColors.blue3,
      borderRadius: borderRadius ?? 8,
      enabled: canLogout && !isLoading,
      onPressed: canLogout && !isLoading ? () => _handleLogout(context) : null,
    );
  }

  Widget _buildIconWithTextButton(BuildContext context, bool isLoading, bool canLogout) {
    if (backgroundColor == Colors.transparent) {
      // Para drawer o lista
      return ListTile(
        leading: isLoading 
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              icon ?? Icons.logout,
              color: iconColor ?? AppColors.red,
            ),
        title: Text(
          isLoading ? 'Cerrando sesión...' : (text ?? 'Cerrar Sesión'),
          style: TextStyle(
            color: textColor ?? AppColors.red,
            fontSize: fontSize ?? 14,
          ),
        ),
        onTap: canLogout && !isLoading ? () => _handleLogout(context) : null,
        enabled: canLogout && !isLoading,
      );
    } else {
      // Widget personalizado que combina icono + CustomButton
      return _buildCustomIconTextButton(context, isLoading, canLogout);
    }
  }

  Widget _buildCustomIconTextButton(BuildContext context, bool isLoading, bool canLogout) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.blue3,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          onTap: canLogout && !isLoading ? () => _handleLogout(context) : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 1,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        textColor ?? Colors.white,
                      ),
                    ),
                  ),
                ] else ...[
                  Icon(
                    icon ?? Icons.logout,
                    color: iconColor ?? textColor ?? Colors.white,
                    size: 16,
                  ),
                ],
                const SizedBox(width: 8),
                Text(
                  isLoading ? 'Cerrando...' : (text ?? 'Cerrar Sesión'),
                  style: AppFont.pirulentBold.style(
                    fontSize: fontSize ?? 10,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    if (showConfirmDialog) {
      _showLogoutConfirmDialog(context);
    } else {
      _executeLogout(context);
    }
  }

  void _showLogoutConfirmDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 300,
        maxHeight: 280,
      ),
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        icon: Icon(
          logoutAll ? Icons.logout_outlined : Icons.logout,
          color: AppColors.red,
          size: 25,
        ),
        title: AppSubtitle(
          logoutAll ? 'Cerrar Todas las Sesiones' : 'Confirmar Cierre de Sesión',
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.all(16),
        content: Text(
          logoutAll
              ? '¿Estás seguro que deseas cerrar sesión en TODOS los dispositivos?\n\n'
                'Esto cerrará tu sesión en todos los lugares donde hayas iniciado sesión.'
              : '¿Estás seguro que deseas cerrar sesión?\n\n'
                'Tendrás que iniciar sesión nuevamente.',
          style: const TextStyle(fontSize: 12),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _executeLogout(context);
            },
            style: ElevatedButton.styleFrom(
              maximumSize: const Size(110, 35),
              minimumSize: const Size(100, 35),
              backgroundColor: logoutAll ? Colors.red : AppColors.blue3,
              foregroundColor: Colors.white,
            ),
            child: Text(
              logoutAll ? 'Cerrar Todas' : 'Cerrar Sesión',
              style: const TextStyle(fontSize: 10),
            ),
          ),
        ],
      ),
    ),
  );
}

  void _executeLogout(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
    } else {
      // ✅ Enviar evento según el tipo de logout
      if (logoutAll) {
        context.read<LoginBloc>().add(const LogoutAllRequested());
      } else {
        context.read<LoginBloc>().add(const LogoutRequested());
      }
    }
  }

  void _navigateToLogin(BuildContext context) {
    // Limpiar stack de navegación y ir al login
    Navigator.pushNamedAndRemoveUntil(
      context,
      'login',
      (route) => false,
    );
  }
}

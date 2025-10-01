// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';


// enum LogoutButtonStyle {
//   iconOnly,
//   textOnly,
//   iconWithText,
// }

// class LogoutButton extends StatelessWidget {
//   final String? text;
//   final IconData? icon;
//   final LogoutButtonStyle style;
//   final VoidCallback? onPressed;
//   final VoidCallback? onLogoutSuccess;
//   final VoidCallback? onLogoutError;
//   final bool showConfirmDialog;
//   final Color? backgroundColor;
//   final Color? textColor;
//   final Color? iconColor;
//   final double? fontSize;
//   final EdgeInsetsGeometry? padding;
//   final double? borderRadius;

//   const LogoutButton({
//     super.key,
//     this.text,
//     this.icon,
//     this.style = LogoutButtonStyle.iconWithText,
//     this.onPressed,
//     this.onLogoutSuccess,
//     this.onLogoutError,
//     this.showConfirmDialog = true,
//     this.backgroundColor,
//     this.textColor,
//     this.iconColor,
//     this.fontSize,
//     this.padding,
//     this.borderRadius,
//   });

//   // Factory para botón de AppBar
//   factory LogoutButton.appBar({
//     IconData? icon = Icons.logout,
//     VoidCallback? onLogoutSuccess,
//     bool showConfirmDialog = true,
//   }) {
//     return LogoutButton(
//       style: LogoutButtonStyle.iconOnly,
//       icon: icon,
//       onLogoutSuccess: onLogoutSuccess,
//       showConfirmDialog: showConfirmDialog,
//       iconColor: AppColors.blue2,
//     );
//   }

//   // Factory para menú lateral
//   factory LogoutButton.drawer({
//     String? text = 'Cerrar Sesión',
//     IconData? icon = Icons.logout,
//     VoidCallback? onLogoutSuccess,
//   }) {
//     return LogoutButton(
//       style: LogoutButtonStyle.iconWithText,
//       text: text,
//       icon: icon,
//       onLogoutSuccess: onLogoutSuccess,
//       backgroundColor: Colors.transparent,
//       textColor: Colors.red,
//       iconColor: Colors.red,
//     );
//   }

//   // Factory para página de perfil
//   factory LogoutButton.profile({
//     String? text = 'Cerrar Sesión',
//     VoidCallback? onLogoutSuccess,
//   }) {
//     return LogoutButton(
//       style: LogoutButtonStyle.textOnly,
//       text: text,
//       onLogoutSuccess: onLogoutSuccess,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       borderRadius: 28,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<LoginBloc, LoginState>(
//       listener: (context, state) {
//         final responseState = state.response;
        
//         // Manejar resultado del logout
//         if (responseState is Success && responseState.data is String) {
//           // Logout exitoso
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (context.mounted) {
//               SnackBarHelper.showSuccess(context, 'Sesión cerrada exitosamente');
              
//               // Callback personalizado o navegación por defecto
//               if (onLogoutSuccess != null) {
//                 onLogoutSuccess!();
//               } else {
//                 _navigateToLogin(context);
//               }
//             }
//           });
          
//         } else if (responseState is Error) {
//           // Error en logout
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (context.mounted) {
//               SnackBarHelper.showError(context, 'Error al cerrar sesión: ${responseState.message}');
              
//               if (onLogoutError != null) {
//                 onLogoutError!();
//               }
//             }
//           });
//         }
//       },
//       builder: (context, state) {
//         final isLoading = state.response is Loading;
//         final canLogout = context.read<LoginBloc>().canLogout;

//         return _buildButton(context, isLoading, canLogout);
//       },
//     );
//   }

//   Widget _buildButton(BuildContext context, bool isLoading, bool canLogout) {
//     switch (style) {
//       case LogoutButtonStyle.iconOnly:
//         return _buildIconButton(context, isLoading, canLogout);
      
//       case LogoutButtonStyle.textOnly:
//         return _buildTextButton(context, isLoading, canLogout);
      
//       case LogoutButtonStyle.iconWithText:
//         return _buildIconWithTextButton(context, isLoading, canLogout);
//     }
//   }

//   Widget _buildIconButton(BuildContext context, bool isLoading, bool canLogout) {
//     return IconButton(
//       onPressed: canLogout && !isLoading ? () => _handleLogout(context) : null,
//       icon: isLoading 
//         ? SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(iconColor ?? Colors.grey),
//             ),
//           )
//         : Icon(
//             icon ?? Icons.logout,
//             color: iconColor ?? AppColors.red,
//           ),
//       tooltip: 'Cerrar Sesión',
//     );
//   }

//   Widget _buildTextButton(BuildContext context, bool isLoading, bool canLogout) {
//     return CustomButton(
//       text: text ?? 'Cerrar Sesión',
//       loadingText: 'Cerrando...',
//       buttonState: isLoading ? ButtonState.loading : ButtonState.idle,
//       textStyle: AppFont.pirulentBold.style(
//         fontSize: fontSize ?? 12,
//         color: textColor ?? Colors.white,
//       ),
//       backgroundColor: backgroundColor ?? AppColors.red,
//       borderRadius: borderRadius ?? 8,
//       enabled: canLogout && !isLoading,
//       onPressed: canLogout && !isLoading ? () => _handleLogout(context) : null,
//     );
//   }

//   Widget _buildIconWithTextButton(BuildContext context, bool isLoading, bool canLogout) {
//     if (backgroundColor == Colors.transparent) {
//       // Para drawer o lista
//       return ListTile(
//         leading: isLoading 
//           ? const SizedBox(
//               width: 24,
//               height: 24,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           : Icon(
//               icon ?? Icons.logout,
//               color: iconColor ?? AppColors.red,
//             ),
//         title: Text(
//           isLoading ? 'Cerrando sesión...' : (text ?? 'Cerrar Sesión'),
//           style: TextStyle(
//             color: textColor ?? AppColors.red,
//             fontSize: fontSize ?? 14,
//           ),
//         ),
//         onTap: canLogout && !isLoading ? () => _handleLogout(context) : null,
//         enabled: canLogout && !isLoading,
//       );
//     } else {
//       // Widget personalizado que combina icono + CustomButton
//       return _buildCustomIconTextButton(context, isLoading, canLogout);
//     }
//   }

//   Widget _buildCustomIconTextButton(BuildContext context, bool isLoading, bool canLogout) {
//     return Container(
//       decoration: BoxDecoration(
//         color: backgroundColor ?? AppColors.red,
//         borderRadius: BorderRadius.circular(borderRadius ?? 8),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(borderRadius ?? 8),
//           onTap: canLogout && !isLoading ? () => _handleLogout(context) : null,
//           child: Padding(
//             padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (isLoading) ...[
//                   SizedBox(
//                     width: 16,
//                     height: 16,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 2,
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         textColor ?? Colors.white,
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   Icon(
//                     icon ?? Icons.logout,
//                     color: iconColor ?? textColor ?? Colors.white,
//                     size: 16,
//                   ),
//                 ],
//                 const SizedBox(width: 8),
//                 Text(
//                   isLoading ? 'Cerrando...' : (text ?? 'Cerrar Sesión'),
//                   style: AppFont.pirulentBold.style(
//                     fontSize: fontSize ?? 12,
//                     color: textColor ?? Colors.white,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _handleLogout(BuildContext context) {
//     if (showConfirmDialog) {
//       _showLogoutConfirmDialog(context);
//     } else {
//       _executeLogout(context);
//     }
//   }

//   void _showLogoutConfirmDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         icon: Icon(Icons.logout, color: AppColors.red, size: 48),
//         title: const Text('Cerrar Sesión'),
//         content: const Text(
//           '¿Estás seguro que deseas cerrar sesión?\n\n'
//           'Tendrás que iniciar sesión nuevamente.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text('Cancelar'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(dialogContext);
//               _executeLogout(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.red,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Cerrar Sesión'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _executeLogout(BuildContext context) {
//     if (onPressed != null) {
//       onPressed!();
//     } else {
//       context.read<LoginBloc>().add(const LogoutRequested());
//     }
//   }

//   void _navigateToLogin(BuildContext context) {
//     // Limpiar stack de navegación y ir al login
//     Navigator.pushNamedAndRemoveUntil(
//       context,
//       'login',
//       (route) => false,
//     );
//   }
// }
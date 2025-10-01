import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leftWidget;
  final String? leftIconPath; // Para SVG o imagen
  final IconData? leftIcon; // Para iconos de Material
  final VoidCallback? onLeftTap;
  final String? title;
  final TextStyle? titleStyle;
  final Color backgroundColor;
  final bool showLogo;
  final String? logoPath; // Path del Lottie
  final double logoSize;
  final double elevation;
  final bool centerTitle;
  final Color? iconColor;
  final SystemUiOverlayStyle? systemOverlayStyle; // NUEVA PROPIEDAD

  const CustomAppBar({
    super.key,
    this.leftWidget,
    this.leftIconPath,
    this.leftIcon,
    this.onLeftTap,
    this.title,
    this.titleStyle,
    this.backgroundColor = Colors.transparent,
    this.showLogo = true,
    this.logoPath = 'assets/animations/logo1.json',
    this.logoSize = 27,
    this.elevation = 0,
    this.centerTitle = true,
    this.iconColor,
    this.systemOverlayStyle, // NUEVA PROPIEDAD
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      // AGREGADO: Configuración del SystemUiOverlayStyle
      systemOverlayStyle: systemOverlayStyle ?? const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Por defecto iconos oscuros
        statusBarBrightness: Brightness.light, // Para iOS
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      title: _buildTitle(),
      leading: _buildLeftWidget(context),
      actions: showLogo ? [_buildLogoWidget()] : null,
      iconTheme: IconThemeData(
        color: iconColor ?? AppColors.blue,
      ),
    );
  }

  Widget? _buildTitle() {
    if (title == null) return null;
    
    return Text(
      title!,
      style: titleStyle ?? AppFont.pirulentBold.style(
        fontSize: 11,
        color: AppColors.blue2,
      ),
    );
  }

  Widget? _buildLeftWidget(BuildContext context) {
    // Si se proporciona un widget personalizado, usarlo
    if (leftWidget != null) {
      return GestureDetector(
        onTap: onLeftTap,
        child: leftWidget!,
      );
    }

    // Si se proporciona un path de imagen/SVG
    if (leftIconPath != null) {
      return GestureDetector(
        onTap: onLeftTap,
        child: Container(
          margin: const EdgeInsets.all(8),
          child: leftIconPath!.endsWith('.svg')
              ? _buildSvgIcon()
              : _buildImageIcon(),
        ),
      );
    }

    // Si se proporciona un icono de Material
    if (leftIcon != null) {
      return IconButton(
        icon: Icon(
          leftIcon!,
          color: iconColor ?? AppColors.blue,
        ),
        onPressed: onLeftTap,
      );
    }

    // Por defecto, mostrar flecha atrás si hay navegación
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: iconColor ?? AppColors.blue,
          size: 20,
        ),
        onPressed: onLeftTap ?? () => Navigator.of(context).pop(),
      );
    }

    return null;
  }

  Widget _buildSvgIcon() {
    // Si tienes flutter_svg instalado
    // return SvgPicture.asset(
    //   leftIconPath!,
    //   width: 24,
    //   height: 24,
    //   colorFilter: ColorFilter.mode(
    //     iconColor ?? AppColors.blue,
    //     BlendMode.srcIn,
    //   ),
    // );
    
    // Fallback si no tienes flutter_svg
    return Icon(
      Icons.image,
      color: iconColor ?? AppColors.blue,
    );
  }

  Widget _buildImageIcon() {
    return Image.asset(
      leftIconPath!,
      width: 20,
      height: 20,
      color: iconColor ?? AppColors.blue,
    );
  }

  Widget _buildLogoWidget() {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Center(
        child: Lottie.asset(
          logoPath!,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Ejemplos de uso del CustomAppBar ACTUALIZADOS

// class AppBarExamples {
  
//   // 1. AppBar básico con logo (para páginas principales)
//   static CustomAppBar basic({String? title}) {
//     return CustomAppBar(
//       title: title,
//       showLogo: true,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//   }

//   // 2. AppBar con flecha atrás (para páginas secundarias)
//   static CustomAppBar withBackButton({
//     String? title,
//     VoidCallback? onBack,
//   }) {
//     return CustomAppBar(
//       title: title,
//       leftIcon: Icons.arrow_back_ios,
//       onLeftTap: onBack,
//       showLogo: true,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarColor: Colors.transparent,
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//         systemNavigationBarColor: Colors.transparent,
//         systemNavigationBarIconBrightness: Brightness.dark,
//       ),
//     );
//   }

//   // 3. AppBar con icono personalizado
//   static CustomAppBar withCustomIcon({
//     String? title,
//     IconData? icon,
//     VoidCallback? onIconTap,
//   }) {
//     return CustomAppBar(
//       title: title,
//       leftIcon: icon,
//       onLeftTap: onIconTap,
//       showLogo: true,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//   }

//   // 4. AppBar con imagen/avatar
//   static CustomAppBar withImage({
//     String? title,
//     String? imagePath,
//     VoidCallback? onImageTap,
//   }) {
//     return CustomAppBar(
//       title: title,
//       leftIconPath: imagePath,
//       onLeftTap: onImageTap,
//       showLogo: true,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//   }

//   // 5. AppBar con widget completamente personalizado
//   static CustomAppBar withCustomWidget({
//     String? title,
//     Widget? customWidget,
//     VoidCallback? onWidgetTap,
//   }) {
//     return CustomAppBar(
//       title: title,
//       leftWidget: customWidget,
//       onLeftTap: onWidgetTap,
//       showLogo: true,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//   }

//   // 6. AppBar sin logo (minimalista)
//   static CustomAppBar withoutLogo({
//     String? title,
//     IconData? leftIcon,
//     VoidCallback? onLeftTap,
//   }) {
//     return CustomAppBar(
//       title: title,
//       leftIcon: leftIcon,
//       onLeftTap: onLeftTap,
//       showLogo: false,
//       systemOverlayStyle: const SystemUiOverlayStyle(
//         statusBarIconBrightness: Brightness.dark,
//         statusBarBrightness: Brightness.light,
//       ),
//     );
//   }

//   // 7. AppBar con fondo colorido
//   static CustomAppBar colored({
//     String? title,
//     Color? backgroundColor,
//     Color? iconColor,
//     Color? textColor,
//   }) {
//     return CustomAppBar(
//       title: title,
//       backgroundColor: backgroundColor ?? AppColors.blue,
//       iconColor: iconColor ?? Colors.white,
//       titleStyle: TextStyle(
//         fontFamily: 'Airstrike',
//         fontSize: 13,
//         fontWeight: FontWeight.w700,
//         color: textColor ?? Colors.white,
//       ),
//       showLogo: true,
//       // Para fondos oscuros, usar iconos claros
//       systemOverlayStyle: SystemUiOverlayStyle(
//         statusBarColor: backgroundColor ?? AppColors.blue,
//         statusBarIconBrightness: Brightness.light, // Iconos claros para fondo oscuro
//         statusBarBrightness: Brightness.dark,
//         systemNavigationBarColor: backgroundColor ?? AppColors.blue,
//         systemNavigationBarIconBrightness: Brightness.light,
//       ),
//     );
//   }

  // NUEVO: AppBar específico para registro con iconos oscuros
  // static CustomAppBar forRegister({
  //   String? title,
  //   VoidCallback? onBack,
  // }) {
  //   return CustomAppBar(
  //     title: title,
  //     centerTitle: false,
  //     showLogo: true,
  //     onLeftTap: onBack,
  //     systemOverlayStyle: const SystemUiOverlayStyle(
  //       statusBarColor: Colors.transparent,
  //       statusBarIconBrightness: Brightness.dark, // Iconos oscuros para registro
  //       statusBarBrightness: Brightness.light,
  //       systemNavigationBarColor: Colors.transparent,
  //       systemNavigationBarIconBrightness: Brightness.dark,
  //       systemNavigationBarDividerColor: Colors.transparent,
  //     ),
  //   );
  // }
// }
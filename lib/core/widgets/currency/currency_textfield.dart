// import 'package:consumo_combustible/core/fonts/app_fonts.dart';
// import 'package:consumo_combustible/core/theme/app_colors.dart';
// import 'package:consumo_combustible/core/widgets/currency/currency_formatter.dart';
// import 'package:flutter/material.dart';

// // Importa el CurrencyFormatterImproved del archivo anterior
// // import 'currency_formatter_improved.dart';

// /// 💰 WIDGET DE CAMPO DE MONEDA ESPECIALIZADO
// /// Hereda el diseño de CustomTextField pero especializado para moneda
// class CurrencyTextField extends StatefulWidget {
//   final String? label;
//   final String? hintText;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final void Function(double)? onChanged;
//   final void Function(double)? onSubmitted;
//   final bool enabled;
//   final Color backgroundColor;
//   final Color? borderColor;
//   final double borderRadius;
//   final EdgeInsetsGeometry? contentPadding;
//   final TextStyle? textStyle;
//   final TextStyle? labelStyle;
//   final TextStyle? hintStyle;
//   final bool filled;
//   final FocusNode? focusNode;
//   final double? height;
//   final double? borderWidth;
  
//   // Propiedades específicas de moneda
//   final String currencySymbol;
//   final int decimalPlaces;
//   final double? minAmount;
//   final double? maxAmount;
//   final bool showSymbolWhenEmpty;
//   final bool showSymbolIcon;
  
//   // ✅ Propiedades del cursor
//   final double? cursorHeight;
//   final double? cursorWidth;
//   final Color? cursorColor;
  
//   // ✅ Mostrar menú contextual (copiar/pegar)
//   final bool showContextMenu;

//   const CurrencyTextField({
//     super.key,
//     this.label,
//     this.hintText,
//     this.controller,
//     this.validator,
//     this.onChanged,
//     this.onSubmitted,
//     this.enabled = true,
//     this.backgroundColor = const Color(0xFFFFFFFF),
//     this.borderColor,
//     this.borderRadius = 6.0,
//     this.contentPadding,
//     this.textStyle,
//     this.labelStyle,
//     this.hintStyle,
//     this.filled = true,
//     this.focusNode,
//     this.height = 35.0,
//     this.borderWidth = 0.5,
//     this.currencySymbol = 'S/',
//     this.decimalPlaces = 2,
//     this.minAmount,
//     this.maxAmount,
//     this.showSymbolWhenEmpty = false,
//     this.showSymbolIcon = false,
//     this.cursorHeight,
//     this.cursorWidth,
//     this.cursorColor,
//     this.showContextMenu = false, // ✅ Por defecto NO mostrar el menú
//   });

//   @override
//   State<CurrencyTextField> createState() => _CurrencyTextFieldState();
// }

// class _CurrencyTextFieldState extends State<CurrencyTextField>
//     with SingleTickerProviderStateMixin {
//   bool _isFocused = false;
//   late FocusNode _focusNode;
//   late AnimationController _animationController;
//   late Animation<double> _shadowAnimation;
//   late Animation<double> _scaleAnimation;

//   // Cache
//   Color? _cachedBorderColor;
//   TextStyle? _cachedTextStyle;
//   TextStyle? _cachedHintStyle;
//   TextStyle? _cachedLabelStyle;
//   BorderRadius? _cachedBorderRadius;
//   EdgeInsetsGeometry? _cachedContentPadding;
//   List<BoxShadow>? _shadowsCache;
//   bool _lastFocusState = false;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _focusNode.addListener(_onFocusChange);

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.fastOutSlowIn,
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.fastOutSlowIn,
//       ),
//     );

//     // ✅ INICIALIZAR con 0.00 si está vacío
//     _initializeController();
    
//     // ✅ LISTENER para evitar selecciones no deseadas
//     if (widget.controller != null && !widget.showContextMenu) {
//       widget.controller!.addListener(_preventAutoSelection);
//     }
//   }

//   // ✅ PREVENIR SELECCIÓN AUTOMÁTICA
//   void _preventAutoSelection() {
//     if (!mounted || widget.controller == null) return;
    
//     // Si hay una selección y no debería haberla, colapsar al final
//     if (widget.controller!.selection.isValid && 
//         widget.controller!.selection.baseOffset != widget.controller!.selection.extentOffset) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && widget.controller != null) {
//           widget.controller!.selection = TextSelection.collapsed(
//             offset: widget.controller!.text.length,
//           );
//         }
//       });
//     }
//   }

//   void _initializeController() {
//     if (widget.controller != null) {
//       // Si el controlador está vacío o es "0", establecer "0.00"
//       if (widget.controller!.text.isEmpty || 
//           widget.controller!.text == '0' ||
//           widget.controller!.text == '0.0') {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted && widget.controller != null) {
//             widget.controller!.text = '0.${'0' * widget.decimalPlaces}';
//             // ✅ MOVER EL CURSOR AL FINAL para evitar que aparezca el toolbar
//             widget.controller!.selection = TextSelection.fromPosition(
//               TextPosition(offset: widget.controller!.text.length),
//             );
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _focusNode.removeListener(_onFocusChange);
//     if (widget.focusNode == null) {
//       _focusNode.dispose();
//     }
//     // ✅ Remover listener del controller
//     if (widget.controller != null && !widget.showContextMenu) {
//       widget.controller!.removeListener(_preventAutoSelection);
//     }
//     super.dispose();
//   }

//   void _onFocusChange() {
//     if (!mounted) return;
//     setState(() {
//       _isFocused = _focusNode.hasFocus;
//     });

//     if (_isFocused) {
//       _animationController.forward();
//       // ✅ SOLUCIÓN: Colapsar la selección al hacer focus
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted && widget.controller != null) {
//           final text = widget.controller!.text;
//           widget.controller!.selection = TextSelection.collapsed(
//             offset: text.length,
//           );
//         }
//       });
//     } else {
//       _animationController.reverse();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return RepaintBoundary(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (widget.label != null) ...[
//             Text(widget.label!, style: _getCachedLabelStyle()),
//             const SizedBox(height: 2),
//           ],
//           AnimatedBuilder(
//             animation: _animationController,
//             builder: (context, child) => _buildTextField(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField() {
//     return Transform.scale(
//       scale: _scaleAnimation.value,
//       child: Container(
//         height: widget.height,
//         decoration: BoxDecoration(
//           color: widget.filled ? widget.backgroundColor : Colors.transparent,
//           borderRadius: _getCachedBorderRadius(),
//           boxShadow: widget.filled ? _getCachedShadows() : null,
//           border: Border.all(
//             color: _getCachedBorderColor(),
//             width: widget.borderWidth ?? 0.5,
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: _getCachedBorderRadius(),
//           child: TextFormField(
//             controller: widget.controller,
//             focusNode: _focusNode,
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             enabled: widget.enabled,
//             maxLines: 1,
//             inputFormatters: [
//               CurrencyFormatterImproved(
//                 symbol: widget.currencySymbol,
//                 decimalPlaces: widget.decimalPlaces,
//               ),
//             ],
//             textAlignVertical: TextAlignVertical.center,
//             textAlign: TextAlign.left,
//             // ✅ AJUSTE DEL CURSOR (configurable)
//             cursorHeight: widget.cursorHeight ?? 14,
//             cursorWidth: widget.cursorWidth ?? 1.5,
//             cursorColor: widget.cursorColor ?? AppColors.blue3,
//             // ✅ EVITAR SELECCIÓN AUTOMÁTICA
//             enableInteractiveSelection: widget.showContextMenu,
//             // ✅ CONTROL DEL MENÚ CONTEXTUAL (copiar/pegar)
//             contextMenuBuilder: widget.showContextMenu 
//                 ? null // Usar el menú por defecto de Flutter
//                 : (context, editableTextState) => const SizedBox.shrink(),
//             onChanged: (value) {
//               if (widget.onChanged != null) {
//                 double numValue = CurrencyUtilsImproved.parseToDouble(value);
//                 widget.onChanged!(numValue);
//               }
//             },
//             onFieldSubmitted: (value) {
//               if (widget.onSubmitted != null) {
//                 double numValue = CurrencyUtilsImproved.parseToDouble(value);
//                 widget.onSubmitted!(numValue);
//               }
//             },
//             validator: widget.validator ?? _defaultValidator,
//             style: _getCachedTextStyle(),
//             decoration: InputDecoration(
//               isDense: true,
//               hintText: widget.hintText ?? '0.00',
//               prefixIcon: widget.showSymbolIcon ? _buildSymbolIcon() : null,
//               prefixIconConstraints: const BoxConstraints(
//                 minWidth: 40,
//                 minHeight: 35,
//               ),
//               // ✅ SIEMPRE mostrar el símbolo (tanto en focus como sin focus)
//               prefixText: '${widget.currencySymbol} ',
//               prefixStyle: _getCachedTextStyle().copyWith(
//                 color: AppColors.blueGrey,
//                 height: 1.0, // ✅ Control de altura de línea
//               ),
//               border: InputBorder.none,
//               focusedBorder: InputBorder.none,
//               enabledBorder: InputBorder.none,
//               disabledBorder: InputBorder.none,
//               errorBorder: InputBorder.none,
//               focusedErrorBorder: InputBorder.none,
//               contentPadding: _getCachedContentPadding(),
//               hintStyle: _getCachedHintStyle(),
//               counterText: '',
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   String? _defaultValidator(String? value) {
//     if (value == null || value.isEmpty) return 'Campo requerido';

//     double amount = CurrencyUtilsImproved.parseToDouble(value);

//     if (amount <= 0) return 'El monto debe ser mayor a 0';

//     if (widget.minAmount != null && amount < widget.minAmount!) {
//       return 'Monto mínimo: ${widget.currencySymbol} ${widget.minAmount!.toStringAsFixed(widget.decimalPlaces)}';
//     }

//     if (widget.maxAmount != null && amount > widget.maxAmount!) {
//       return 'Monto máximo: ${widget.currencySymbol} ${widget.maxAmount!.toStringAsFixed(widget.decimalPlaces)}';
//     }

//     return null;
//   }

//   Widget? _buildSymbolIcon() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       child: Icon(
//         Icons.attach_money_outlined,
//         color: widget.borderColor ?? AppColors.blue3,
//         size: 20,
//       ),
//     );
//   }

//   // MÉTODOS DE CACHE
//   Color _getCachedBorderColor() {
//     return _cachedBorderColor ??= widget.borderColor ??
//         (_isFocused
//             ? const Color(0xFFE0E0E0)
//             : const Color(0xFFF0F0F0));
//   }

//   TextStyle _getCachedTextStyle() {
//     return _cachedTextStyle ??= widget.textStyle ??
//         TextStyle(
//           color: widget.enabled ? AppColors.blue2 : AppColors.blue3,
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//           fontFamily: 'Oxygen-Regular',
//           height: 1.0, // ✅ Control de altura de línea para centrado
//         );
//   }

//   TextStyle _getCachedHintStyle() {
//     return _cachedHintStyle ??= widget.hintStyle ??
//         TextStyle(
//           color: Colors.grey[500],
//           fontSize: 10,
//           fontWeight: FontWeight.w400,
//           height: 1.0, // ✅ Control de altura de línea para centrado
//         );
//   }

//   TextStyle _getCachedLabelStyle() {
//     return _cachedLabelStyle ??= widget.labelStyle ??
//         TextStyle(
//           fontSize: 9,
//           fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
//           color: AppColors.blue3,
//         );
//   }

//   BorderRadius _getCachedBorderRadius() {
//     return _cachedBorderRadius ??= BorderRadius.circular(widget.borderRadius);
//   }

//   EdgeInsetsGeometry _getCachedContentPadding() {
//     if (_cachedContentPadding != null) return _cachedContentPadding!;
    
//     if (widget.contentPadding != null) {
//       _cachedContentPadding = widget.contentPadding;
//       return _cachedContentPadding!;
//     }

//     // ✅ AJUSTE ESPECÍFICO POR ALTURA PARA CENTRADO PERFECTO
//     if (widget.height == 38) {
//       _cachedContentPadding = const EdgeInsets.fromLTRB(16, 12, 16, 11);
//     } else if (widget.height == 35) {
//       _cachedContentPadding = const EdgeInsets.fromLTRB(16, 10.5, 16, 10);
//     } else if (widget.height == 40) {
//       _cachedContentPadding = const EdgeInsets.fromLTRB(16, 13, 16, 12);
//     } else {
//       // Cálculo dinámico para otras alturas
//       double fontSize = _getCachedTextStyle().fontSize ?? 10;
//       double textHeight = fontSize * 1.5;
//       double verticalPadding = ((widget.height ?? 35) - textHeight) / 2;
//       _cachedContentPadding = EdgeInsets.symmetric(
//         horizontal: 16,
//         vertical: verticalPadding.clamp(8.0, 15.0),
//       );
//     }
    
//     return _cachedContentPadding!;
//   }

//   List<BoxShadow> _getCachedShadows() {
//     if (_shadowsCache == null || _lastFocusState != _isFocused) {
//       _shadowsCache = _buildShadows();
//       _lastFocusState = _isFocused;
//     }
//     return _shadowsCache!;
//   }

//   List<BoxShadow> _buildShadows() {
//     final double intensity = _shadowAnimation.value;
//     final Color currentBorderColor = _getCachedBorderColor();
//     Color shadowColor = _getShadowColor(currentBorderColor);

//     if (_isFocused) {
//       return [
//         BoxShadow(
//           color: currentBorderColor.withOpacity(0.3 + (intensity * 0.2)),
//           offset: const Offset(0, 3),
//           blurRadius: 4 + (intensity * 2),
//           spreadRadius: 0,
//         ),
//         BoxShadow(
//           color: Colors.white.withOpacity(0.6),
//           offset: const Offset(-1, -1),
//           blurRadius: 2,
//           spreadRadius: -1,
//         ),
//       ];
//     } else {
//       return [
//         BoxShadow(
//           color: shadowColor.withOpacity(0.18),
//           offset: const Offset(4, 4),
//           blurRadius: 8,
//           spreadRadius: 0,
//         ),
//         BoxShadow(
//           color: currentBorderColor.withOpacity(0.15),
//           offset: const Offset(1, 1),
//           blurRadius: 4,
//           spreadRadius: -1,
//         ),
//         BoxShadow(
//           color: Colors.white.withOpacity(0.8),
//           offset: const Offset(-2, -2),
//           blurRadius: 4,
//           spreadRadius: -1,
//         ),
//       ];
//     }
//   }

//   Color _getShadowColor(Color borderColor) {
//     if (borderColor == AppColors.blue || borderColor == const Color(0xFF1976D2)) {
//       return const Color(0xFF0D47A1);
//     } else if (borderColor == Colors.green || borderColor == const Color(0xFF4CAF50)) {
//       return const Color(0xFF1B5E20);
//     } else {
//       HSLColor hsl = HSLColor.fromColor(borderColor);
//       return HSLColor.fromAHSL(
//         1.0,
//         hsl.hue,
//         (hsl.saturation * 0.9).clamp(0.0, 1.0),
//         (hsl.lightness * 0.25).clamp(0.0, 0.4),
//       ).toColor();
//     }
//   }
// }

// /// 💰 HELPER PARA CREAR CAMPO DE MONEDA FÁCILMENTE
// class CurrencyTextFieldHelper {
//   static CurrencyTextField create({
//     required String label,
//     required TextEditingController controller,
//     String? hintText,
//     String currencySymbol = 'S/',
//     double? minAmount,
//     double? maxAmount,
//     Color? borderColor,
//     void Function(double)? onChanged,
//     bool enabled = true,
//     double? height,
//     bool showSymbolWhenEmpty = false,
//     bool showSymbolIcon = false,
//     double? cursorHeight,
//     double? cursorWidth,
//     Color? cursorColor,
//     bool showContextMenu = false,
//   }) {
//     return CurrencyTextField(
//       label: label,
//       controller: controller,
//       hintText: hintText,
//       currencySymbol: currencySymbol,
//       minAmount: minAmount,
//       maxAmount: maxAmount,
//       borderColor: borderColor,
//       onChanged: onChanged,
//       enabled: enabled,
//       height: height ?? 38,
//       showSymbolWhenEmpty: showSymbolWhenEmpty,
//       showSymbolIcon: showSymbolIcon,
//       cursorHeight: cursorHeight,
//       cursorWidth: cursorWidth,
//       cursorColor: cursorColor,
//       showContextMenu: showContextMenu,
//     );
//   }
// }

import 'dart:async';
import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/currency/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🚀 MEJORA: Estados de validación (igual que CustomTextField)
sealed class ValidationState {
  const ValidationState();
}

class ValidationNone extends ValidationState {
  const ValidationNone();
}

class ValidationLoading extends ValidationState {
  const ValidationLoading();
}

class ValidationValid extends ValidationState {
  const ValidationValid();
}

class ValidationInvalid extends ValidationState {
  final String error;
  const ValidationInvalid(this.error);
}

// 🚀 MANAGER DE VALIDACIÓN (igual que CustomTextField)
class CurrencyValidationManager {
  Timer? _timer;
  final ValueNotifier<ValidationState> state = ValueNotifier(const ValidationNone());
  final ValueNotifier<String?> error = ValueNotifier(null);
  bool _disposed = false;
  
  void startValidation(
    String value,
    Duration delay,
    String? Function(String?)? validator,
  ) {
    if (_disposed) return;
    
    _timer?.cancel();
    state.value = const ValidationLoading();
    
    _timer = Timer(delay, () {
      if (_disposed) return;
      
      final result = validator?.call(value);
      
      if (_disposed) return;
      
      if (result != null) {
        state.value = ValidationInvalid(result);
        error.value = result;
      } else {
        state.value = const ValidationValid();
        error.value = null;
      }
    });
  }
  
  void clearValidation() {
    if (_disposed) return;
    
    _timer?.cancel();
    state.value = const ValidationNone();
    error.value = null;
  }
  
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    state.dispose();
    error.dispose();
  }
}

/// 💰 WIDGET DE CAMPO DE MONEDA MEJORADO
/// Ahora con validación en tiempo real y errores externos como CustomTextField
class CurrencyTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(double)? onChanged;
  final void Function(double)? onSubmitted;
  final bool enabled;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool filled;
  final FocusNode? focusNode;
  final double? height;
  final double? borderWidth;
  
  // Propiedades específicas de moneda
  final String currencySymbol;
  final int decimalPlaces;
  final double? minAmount;
  final double? maxAmount;
  final bool showSymbolWhenEmpty;
  final bool showSymbolIcon;
  
  // ✅ Propiedades del cursor
  final double? cursorHeight;
  final double? cursorWidth;
  final Color? cursorColor;
  
  // ✅ Mostrar menú contextual (copiar/pegar)
  final bool showContextMenu;
  
  // 🚀 NUEVO: Validación en tiempo real
  final bool enableRealTimeValidation;
  final Duration validationDelay;

  const CurrencyTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor,
    this.borderRadius = 6.0,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.filled = true,
    this.focusNode,
    this.height = 35.0,
    this.borderWidth = 0.5,
    this.currencySymbol = 'S/',
    this.decimalPlaces = 2,
    this.minAmount,
    this.maxAmount,
    this.showSymbolWhenEmpty = false,
    this.showSymbolIcon = false,
    this.cursorHeight,
    this.cursorWidth,
    this.cursorColor,
    this.showContextMenu = false,
    this.enableRealTimeValidation = true, // 🚀 NUEVO
    this.validationDelay = const Duration(milliseconds: 800), // 🚀 NUEVO
  });

  @override
  State<CurrencyTextField> createState() => _CurrencyTextFieldState();
}

class _CurrencyTextFieldState extends State<CurrencyTextField>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _shadowAnimation;
  late Animation<double> _scaleAnimation;
  late CurrencyValidationManager _validationManager; // 🚀 NUEVO

  // Cache
  Color? _cachedBorderColor;
  TextStyle? _cachedTextStyle;
  TextStyle? _cachedHintStyle;
  TextStyle? _cachedLabelStyle;
  BorderRadius? _cachedBorderRadius;
  EdgeInsetsGeometry? _cachedContentPadding;
  List<BoxShadow>? _shadowsCache;
  bool _lastFocusState = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    
    // 🚀 NUEVO: Inicializar el manager de validación
    _validationManager = CurrencyValidationManager();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _initializeController();
    
    if (widget.controller != null && !widget.showContextMenu) {
      widget.controller!.addListener(_preventAutoSelection);
    }
  }

  void _preventAutoSelection() {
    if (!mounted || widget.controller == null) return;
    
    if (widget.controller!.selection.isValid && 
        widget.controller!.selection.baseOffset != widget.controller!.selection.extentOffset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller != null) {
          widget.controller!.selection = TextSelection.collapsed(
            offset: widget.controller!.text.length,
          );
        }
      });
    }
  }

  void _initializeController() {
    if (widget.controller != null) {
      if (widget.controller!.text.isEmpty || 
          widget.controller!.text == '0' ||
          widget.controller!.text == '0.0') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.controller != null) {
            widget.controller!.text = '0.${'0' * widget.decimalPlaces}';
            widget.controller!.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller!.text.length),
            );
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller != null && !widget.showContextMenu) {
      widget.controller!.removeListener(_preventAutoSelection);
    }
    _validationManager.dispose(); // 🚀 NUEVO
    super.dispose();
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.controller != null) {
          final text = widget.controller!.text;
          widget.controller!.selection = TextSelection.collapsed(
            offset: text.length,
          );
        }
      });
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(widget.label!, style: _getCachedLabelStyle()),
            const SizedBox(height: 2),
          ],
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) => _buildTextField(),
          ),
          // 🚀 NUEVO: Error message como widget separado (igual que CustomTextField)
          _buildErrorMessage(),
        ],
      ),
    );
  }

  // 🚀 NUEVO: Error message separado (igual que CustomTextField)
  Widget _buildErrorMessage() {
    if (!widget.enableRealTimeValidation) return const SizedBox.shrink();
    
    return ValueListenableBuilder<ValidationState>(
      valueListenable: _validationManager.state,
      builder: (context, state, child) {
        if (state is ValidationInvalid) {
          return Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              state.error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTextField() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.filled ? widget.backgroundColor : Colors.transparent,
          borderRadius: _getCachedBorderRadius(),
          boxShadow: widget.filled ? _getCachedShadows() : null,
          border: Border.all(
            color: _getCachedBorderColor(),
            width: widget.borderWidth ?? 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: _getCachedBorderRadius(),
          child: TextFormField( // ✅ TextFormField para compatibilidad con Form
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: widget.enabled,
            maxLines: 1,
            inputFormatters: [
              CurrencyFormatterImproved(
                symbol: widget.currencySymbol,
                decimalPlaces: widget.decimalPlaces,
              ),
            ],
            cursorHeight: widget.cursorHeight ?? 14,
            cursorWidth: widget.cursorWidth ?? 1.5,
            cursorColor: widget.cursorColor ?? AppColors.blue2,
            enableInteractiveSelection: widget.showContextMenu,
            contextMenuBuilder: widget.showContextMenu 
                ? null 
                : (context, editableTextState) => const SizedBox.shrink(),
            // 🚀 VALIDACIÓN: Solo para Form.validate(), no muestra errores internos
            validator: widget.enableRealTimeValidation 
                ? null // Si usamos validación en tiempo real, no usar el validador interno
                : _getCombinedValidator(), // Si no, usar validador para Form.validate()
            autovalidateMode: AutovalidateMode.disabled, // ✅ Nunca mostrar errores internos
            // 🚀 NUEVO: Validación en tiempo real
            onChanged: (value) {
              if (widget.enableRealTimeValidation && value.isNotEmpty) {
                _validationManager.startValidation(
                  value,
                  widget.validationDelay,
                  _getCombinedValidator(),
                );
              }
              
              if (widget.onChanged != null) {
                double numValue = CurrencyUtilsImproved.parseToDouble(value);
                widget.onChanged!(numValue);
              }
            },
            onFieldSubmitted: (value) {
              if (widget.onSubmitted != null) {
                double numValue = CurrencyUtilsImproved.parseToDouble(value);
                widget.onSubmitted!(numValue);
              }
            },
            style: _getCachedTextStyle(),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hintText ?? '0.00',
              prefixIcon: widget.showSymbolIcon ? _buildSymbolIcon() : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 35,
              ),
              prefixText: '${widget.currencySymbol} ',
              prefixStyle: _getCachedTextStyle().copyWith(
                color: AppColors.blueGrey,
                height: 1.0,
              ),
              // 🚀 NUEVO: Sufijo con icono de validación
              suffixIcon: widget.enableRealTimeValidation 
                  ? _buildValidationIcon() 
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 35,
              ),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: _getCachedContentPadding(),
              hintStyle: _getCachedHintStyle(),
              counterText: '',
            ),
          ),
        ),
      ),
    );
  }

  // 🚀 NUEVO: Icono de validación (igual que CustomTextField)
  Widget _buildValidationIcon() {
    return ValueListenableBuilder<ValidationState>(
      valueListenable: _validationManager.state,
      builder: (context, state, child) {
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: 16,
            height: 16,
            child: Center(
              child: switch (state) {
                ValidationLoading() => const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                  ),
                ),
                ValidationValid() => const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                ValidationInvalid() => const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 16,
                ),
                ValidationNone() => const SizedBox.shrink(),
              },
            ),
          ),
        );
      },
    );
  }

  // 🚀 NUEVO: Combinar validador personalizado con validador por defecto
  String? Function(String?) _getCombinedValidator() {
    return (value) {
      // Primero ejecutar el validador por defecto
      final defaultError = _defaultValidator(value);
      if (defaultError != null) return defaultError;
      
      // Luego ejecutar el validador personalizado si existe
      if (widget.validator != null) {
        return widget.validator!(value);
      }
      
      return null;
    };
  }

  // 🚀 NUEVO: Método público para validar manualmente (útil para Form.validate())
  String? validate() {
    return _getCombinedValidator()(widget.controller?.text);
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    double amount = CurrencyUtilsImproved.parseToDouble(value);

    if (amount <= 0) return 'El monto debe ser mayor a 0';

    if (widget.minAmount != null && amount < widget.minAmount!) {
      return 'Monto mínimo: ${widget.currencySymbol} ${widget.minAmount!.toStringAsFixed(widget.decimalPlaces)}';
    }

    if (widget.maxAmount != null && amount > widget.maxAmount!) {
      return 'Monto máximo: ${widget.currencySymbol} ${widget.maxAmount!.toStringAsFixed(widget.decimalPlaces)}';
    }

    return null;
  }

  Widget? _buildSymbolIcon() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.attach_money_outlined,
        color: widget.borderColor ?? AppColors.blue3,
        size: 20,
      ),
    );
  }

  // MÉTODOS DE CACHE
  Color _getCachedBorderColor() {
    return _cachedBorderColor ??= widget.borderColor ??
        (_isFocused
            ? const Color(0xFFE0E0E0)
            : const Color(0xFFF0F0F0));
  }

  TextStyle _getCachedTextStyle() {
    return _cachedTextStyle ??= widget.textStyle ??
        TextStyle(
          color: widget.enabled ? AppColors.blue2 : AppColors.blue3,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          fontFamily: 'Oxygen-Regular',
          height: 1.0,
        );
  }

  TextStyle _getCachedHintStyle() {
    return _cachedHintStyle ??= widget.hintStyle ??
        TextStyle(
          color: Colors.grey[500],
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.0,
        );
  }

  TextStyle _getCachedLabelStyle() {
    return _cachedLabelStyle ??= widget.labelStyle ??
        TextStyle(
          fontSize: 9,
          fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
          color: AppColors.blue3,
        );
  }

  BorderRadius _getCachedBorderRadius() {
    return _cachedBorderRadius ??= BorderRadius.circular(widget.borderRadius);
  }

  EdgeInsetsGeometry _getCachedContentPadding() {
    if (_cachedContentPadding != null) return _cachedContentPadding!;
    
    if (widget.contentPadding != null) {
      _cachedContentPadding = widget.contentPadding;
      return _cachedContentPadding!;
    }

    // ✅ AJUSTE ESPECÍFICO POR ALTURA PARA CENTRADO PERFECTO
    if (widget.height == 38) {
      _cachedContentPadding = const EdgeInsets.fromLTRB(16, 12, 16, 11);
    } else if (widget.height == 35) {
      _cachedContentPadding = const EdgeInsets.fromLTRB(16, 10.5, 16, 10);
    } else if (widget.height == 40) {
      _cachedContentPadding = const EdgeInsets.fromLTRB(16, 13, 16, 12);
    } else {
      // Cálculo dinámico para otras alturas
      double fontSize = _getCachedTextStyle().fontSize ?? 10;
      double textHeight = fontSize * 1.5;
      double verticalPadding = ((widget.height ?? 35) - textHeight) / 2;
      _cachedContentPadding = EdgeInsets.symmetric(
        horizontal: 16,
        vertical: verticalPadding.clamp(8.0, 15.0),
      );
    }
    
    return _cachedContentPadding!;
  }

  List<BoxShadow> _getCachedShadows() {
    if (_shadowsCache == null || _lastFocusState != _isFocused) {
      _shadowsCache = _buildShadows();
      _lastFocusState = _isFocused;
    }
    return _shadowsCache!;
  }

  List<BoxShadow> _buildShadows() {
    final double intensity = _shadowAnimation.value;
    final Color currentBorderColor = _getCachedBorderColor();
    Color shadowColor = _getShadowColor(currentBorderColor);

    if (_isFocused) {
      return [
        BoxShadow(
          color: currentBorderColor.withOpacity(0.3 + (intensity * 0.2)),
          offset: const Offset(0, 3),
          blurRadius: 4 + (intensity * 2),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.6),
          offset: const Offset(-1, -1),
          blurRadius: 2,
          spreadRadius: -1,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: shadowColor.withOpacity(0.18),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: currentBorderColor.withOpacity(0.15),
          offset: const Offset(1, 1),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.8),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];
    }
  }

  Color _getShadowColor(Color borderColor) {
    if (borderColor == AppColors.blue || borderColor == const Color(0xFF1976D2)) {
      return const Color(0xFF0D47A1);
    } else if (borderColor == Colors.green || borderColor == const Color(0xFF4CAF50)) {
      return const Color(0xFF1B5E20);
    } else {
      HSLColor hsl = HSLColor.fromColor(borderColor);
      return HSLColor.fromAHSL(
        1.0,
        hsl.hue,
        (hsl.saturation * 0.9).clamp(0.0, 1.0),
        (hsl.lightness * 0.25).clamp(0.0, 0.4),
      ).toColor();
    }
  }
}

/// 💰 HELPER MEJORADO PARA CREAR CAMPO DE MONEDA
class CurrencyTextFieldHelper {
  static CurrencyTextField create({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String currencySymbol = 'S/',
    double? minAmount,
    double? maxAmount,
    Color? borderColor,
    void Function(double)? onChanged,
    bool enabled = true,
    double? height,
    bool showSymbolWhenEmpty = false,
    bool showSymbolIcon = false,
    double? cursorHeight,
    double? cursorWidth,
    Color? cursorColor,
    bool showContextMenu = false,
    bool enableRealTimeValidation = true, // 🚀 NUEVO
    Duration? validationDelay, // 🚀 NUEVO
    String? Function(String?)? validator, // 🚀 NUEVO
  }) {
    return CurrencyTextField(
      label: label,
      controller: controller,
      hintText: hintText,
      currencySymbol: currencySymbol,
      minAmount: minAmount,
      maxAmount: maxAmount,
      borderColor: borderColor,
      onChanged: onChanged,
      enabled: enabled,
      height: height ?? 38,
      showSymbolWhenEmpty: showSymbolWhenEmpty,
      showSymbolIcon: showSymbolIcon,
      cursorHeight: cursorHeight,
      cursorWidth: cursorWidth,
      cursorColor: cursorColor,
      showContextMenu: showContextMenu,
      enableRealTimeValidation: enableRealTimeValidation,
      validationDelay: validationDelay ?? const Duration(milliseconds: 800),
      validator: validator,
    );
  }
}
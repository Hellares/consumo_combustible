import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

// Enums para tipos de campo
enum FieldType { text, email, phone, currency, url, dni, ruc, password }

// 🚀 MEJORA: Usar sealed classes para type safety
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

// ENUM PARA PAÍSES (MEJORADO)
enum CountryCode {
  peru('+51', 9),
  colombia('+57', 10),
  ecuador('+593', 9),
  chile('+56', 9);

  const CountryCode(this.code, this.phoneLength);
  final String code;
  final int phoneLength;
}

// CONSTANTES CENTRALIZADAS
class CustomTextFieldConstants {
  static const Duration defaultValidationDelay = Duration(milliseconds: 800);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const double defaultHeight = 35.0; //!ALTURA DEL TEXTBOX
  static const double defaultBorderRadius = 6.0;
  static const double defaultBorderWidth = 0.5;
  static const int defaultDecimalPlaces = 2;

  // Colores por defecto
  static const Color defaultBackgroundColor = Color.fromARGB(255, 255, 255, 255);
  static const Color defaultFocusedBorderColor = Color(0xFFE0E0E0);
  static const Color defaultBorderColor = Color(0xFFF0F0F0);

  // 🚀 MEJORA: Widgets constantes para mejor performance
  static const Widget loadingIndicator = SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  static const Widget validIcon = Icon(
    Icons.check_circle, 
    color: Colors.green, 
    size: 16
  );

  static const Widget invalidIcon = Icon(
    Icons.error, 
    color: Colors.red, 
    size: 16
  );
}

class ValidationManager {
  Timer? _timer;
  final ValueNotifier<ValidationState> state = ValueNotifier(const ValidationNone());
  final ValueNotifier<String?> error = ValueNotifier(null);
  bool _disposed = false; // Flag para controlar el estado
  
  void startValidation(
    String value, 
    FieldType type, 
    Duration delay,
    String? Function(String?)? validator,
    Future<String?> Function(String)? asyncValidator,
    CountryCode country,
  ) {
    if (_disposed) return; // Verificar si ya fue disposed
    
    _timer?.cancel();
    state.value = const ValidationLoading();
    
    _timer = Timer(delay, () async {
      if (_disposed) return; // Verificar antes de la validación async
      
      final result = await _validate(value, type, validator, asyncValidator, country);
      
      if (_disposed) return; // Verificar después de la validación async
      
      if (result != null) {
        state.value = ValidationInvalid(result);
        error.value = result;
      } else {
        state.value = const ValidationValid();
        error.value = null;
      }
    });
  }

  Future<String?> _validate(
    String value,
    FieldType type,
    String? Function(String?)? validator,
    Future<String?> Function(String)? asyncValidator,
    CountryCode country,
  ) async {
    String? error;

    // Tu lógica de validación actual...
    switch (type) {
      case FieldType.email:
        error = FieldValidators.validateEmail(value);
        break;
      case FieldType.phone:
        error = FieldValidators.validatePhone(value, country: country);
        break;
      case FieldType.currency:
        error = FieldValidators.validateCurrency(value);
        break;
      case FieldType.url:
        error = FieldValidators.validateUrl(value);
        break;
      case FieldType.dni:
        error = FieldValidators.validateDni(value);
        break;
      case FieldType.ruc:
        error = FieldValidators.validateRuc(value);
        break;
      case FieldType.password:
        error = FieldValidators.validatePassword(value);
        break;
      default:
        break;
    }

    if (error == null && validator != null) {
      error = validator(value);
    }

    if (error == null && asyncValidator != null) {
      try {
        error = await asyncValidator(value);
      } catch (e) {
        error = 'Error de validación';
      }
    }

    return error;
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

// FORMATEADOR DE MONEDA MEJORADO
class CurrencyFormatter extends TextInputFormatter {
  final String symbol;
  final int decimalPlaces;

  CurrencyFormatter({
    this.symbol = 'S/',
    this.decimalPlaces = CustomTextFieldConstants.defaultDecimalPlaces,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    List<String> parts = digitsOnly.split('.');
    if (parts.length > 2) {
      parts = [parts[0], parts.sublist(1).join('')];
    }

    if (parts.length == 2 && parts[1].length > decimalPlaces) {
      parts[1] = parts[1].substring(0, decimalPlaces);
    }

    String integerPart = parts[0];
    if (integerPart.isNotEmpty) {
      integerPart = _addThousandsSeparator(integerPart);
    }

    String formatted = integerPart;
    if (parts.length == 2) {
      formatted += '.${parts[1]}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addThousandsSeparator(String number) {
    if (number.length <= 3) return number;

    String reversed = number.split('').reversed.join('');
    String withCommas = '';
    for (int i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) {
        withCommas += ',';
      }
      withCommas += reversed[i];
    }
    return withCommas.split('').reversed.join('');
  }
}

// UTILIDADES DE MONEDA MEJORADAS
class CurrencyUtils {
  static String formatForDisplay(String value, String symbol) {
    if (value.isEmpty) return '';
    return '$symbol $value';
  }

  static String extractNumericValue(String formattedValue, String symbol) {
    if (formattedValue.isEmpty) return '';
    return formattedValue.replaceFirst('$symbol ', '').replaceAll(',', '');
  }

  static double parseToDouble(String value) {
    if (value.isEmpty) return 0.0;
    String cleaned = value.replaceAll(',', '');

    if (!cleaned.contains('.')) {
      cleaned += '.00';
    } else {
      List<String> parts = cleaned.split('.');
      if (parts.length == 2) {
        if (parts[1].length == 1) {
          parts[1] += '0';
        } else if (parts[1].length > 2) {
          parts[1] = parts[1].substring(0, 2);
        }
        cleaned = '${parts[0]}.${parts[1]}';
      }
    }

    return double.tryParse(cleaned) ?? 0.0;
  }

  static String formatWithDecimals(double value) {
    return value.toStringAsFixed(2);
  }

  static String getValueAsString(double value) {
    return value.toStringAsFixed(2);
  }

  static bool isValidCurrency(String value) {
    if (value.isEmpty) return false;
    String cleaned = value.replaceAll(',', '');
    return double.tryParse(cleaned) != null;
  }
}

// UTILIDADES DE TELÉFONO MEJORADAS
class PhoneUtils {
  static String getPhoneForDatabase(String value, CountryCode country) {
    if (value.isEmpty) return '';
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    return '${country.code}$digitsOnly';
  }

  static bool isValidPhone(String value, CountryCode country) {
    if (value.isEmpty) return false;
    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    return digitsOnly.length == country.phoneLength;
  }

  static String formatFromDatabase(String dbValue, CountryCode country) {
    if (dbValue.isEmpty) return '';
    String digitsOnly = dbValue
        .replaceFirst(country.code, '')
        .replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length == country.phoneLength) {
      switch (country) {
        case CountryCode.peru:
        case CountryCode.ecuador:
        case CountryCode.chile:
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
        case CountryCode.colombia:
          return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 3 + 3)} ${digitsOnly.substring(6)}';
      }
    }
    return digitsOnly;
  }
}

// FORMATEADOR DE TELÉFONO
class PhoneFormatterDynamic extends TextInputFormatter {
  final CountryCode country;
  final int maxDigits;

  PhoneFormatterDynamic({required this.country})
    : maxDigits = country.phoneLength;

  factory PhoneFormatterDynamic.fromCountry(CountryCode country) =>
      PhoneFormatterDynamic(country: country);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (digitsOnly.length > maxDigits) {
      digitsOnly = digitsOnly.substring(0, maxDigits);
    }

    String formatted = _formatByCountry(digitsOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatByCountry(String digits) {
    switch (country) {
      case CountryCode.peru:
      case CountryCode.ecuador:
      case CountryCode.chile:
        if (digits.length <= 3) {
          return digits;
        } else if (digits.length <= 6) {
          return '${digits.substring(0, 3)} ${digits.substring(3)}';
        } else {
          return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
        }
      case CountryCode.colombia:
        if (digits.length <= 3) {
          return digits;
        } else if (digits.length <= 6) {
          return '${digits.substring(0, 3)} ${digits.substring(3)}';
        } else {
          return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6)}';
        }
    }
  }
}

// FORMATEADOR DE DNI
class DniFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (digitsOnly.length > 8) {
      digitsOnly = digitsOnly.substring(0, 8);
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

// FORMATEADOR DE RUC
class RucFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    if (digitsOnly.length > 11) {
      digitsOnly = digitsOnly.substring(0, 11);
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

// VALIDADORES MEJORADOS
class FieldValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) return 'Email inválido';

    if (value.length > 254) return 'Email demasiado largo';
    if (value.contains('..')) return 'Email inválido';

    return null;
  }

  static String? validatePhone(String? value, {required CountryCode country}) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    if (!PhoneUtils.isValidPhone(value, country)) {
      return 'Teléfono debe tener ${country.phoneLength} dígitos';
    }

    return null;
  }

  static String? validateCurrency(
    String? value, {
    double? minAmount,
    double? maxAmount,
  }) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    if (!CurrencyUtils.isValidCurrency(value)) {
      return 'Monto inválido';
    }

    double amount = CurrencyUtils.parseToDouble(value);

    if (amount <= 0) return 'El monto debe ser mayor a 0';

    if (minAmount != null && amount < minAmount) {
      return 'Monto mínimo: S/ ${minAmount.toStringAsFixed(2)}';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Monto máximo: S/ ${maxAmount.toStringAsFixed(2)}';
    }

    return null;
  }

  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';
    final urlRegex = RegExp(
      r'^https?://[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$',
    );
    if (!urlRegex.hasMatch(value)) return 'URL inválida';
    return null;
  }

  static String? validateDni(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length != 8) {
      return 'DNI debe tener 8 dígitos';
    }

    return null;
  }

  static String? validateRuc(String? value) {
    if (value == null || value.isEmpty) return 'Campo requerido';

    String digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length != 11) {
      return 'RUC debe tener 11 dígitos';
    }

    return null;
  }

  static String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Campo requerido';
  }

  if (value.length < 6) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }

  return null;
}
}

// 🚀 WIDGET PRINCIPAL OPTIMIZADO
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final Color backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final Color? colorIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool filled;
  final FocusNode? focusNode;
  final double? height;
  final double? borderWidth;

  // Propiedades de validación y formateo
  final FieldType fieldType;
  final bool showValidationIndicator;
  final Duration validationDelay;
  final Future<String?> Function(String)? asyncValidator;
  final CountryCode country;
  final String currencySymbol;
  final bool enableRealTimeValidation;
  
  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    // this.obscureText = false,
    bool? obscureText,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.backgroundColor = CustomTextFieldConstants.defaultBackgroundColor,
    this.borderColor,
    this.borderRadius = CustomTextFieldConstants.defaultBorderRadius,
    this.colorIcon,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.filled = true,
    this.focusNode,
    this.height = CustomTextFieldConstants.defaultHeight,
    this.borderWidth = CustomTextFieldConstants.defaultBorderWidth,
    this.fieldType = FieldType.text,
    this.showValidationIndicator = true,
    this.validationDelay = CustomTextFieldConstants.defaultValidationDelay,
    this.asyncValidator,
    this.country = CountryCode.peru,
    this.currencySymbol = 'S/',
    this.enableRealTimeValidation = true,
  }) : obscureText = fieldType == FieldType.password ? true : (obscureText ?? false);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  bool _hasText = false;
  bool _isObscured = false;

  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _shadowAnimation;
  late Animation<double> _scaleAnimation;

  // 🚀 MEJORA: Usar ValidationManager dedicado
  late ValidationManager _validationManager;

  // 🚀 MEJORA: Cache más inteligente
  Color? _cachedBorderColor;
  Color? _cachedShadowColor;
  TextStyle? _cachedTextStyle;
  TextStyle? _cachedHintStyle;
  TextStyle? _cachedLabelStyle;
  BorderRadius? _cachedBorderRadius;
  EdgeInsetsGeometry? _cachedContentPadding;
  List<TextInputFormatter>? _formattersCache;
  String? _lastFieldTypeString;
  TextInputType? _cachedKeyboardType;
  Widget? _cachedPrefixIcon;
  String? _cachedPrefixText;
  List<BoxShadow>? _shadowsCache;
  bool _lastFocusState = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _validationManager = ValidationManager();

    _animationController = AnimationController(
      duration: CustomTextFieldConstants.defaultAnimationDuration,
      vsync: this,
    );

    // 🚀 MEJORA: Curve más performante
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

    if (widget.controller != null) {
      _hasText = widget.controller!.text.isNotEmpty;
      widget.controller!.addListener(_onTextChanged);
    }
  }

  // 🚀 MEJORA: dispose() corregido para evitar memory leaks
  @override
  void dispose() {
    _validationManager.dispose();
    _animationController.dispose();
    
    // IMPORTANTE: Remover el listener ANTES de dispose
    _focusNode.removeListener(_onFocusChange);
    
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller != null) {
      widget.controller!.removeListener(_onTextChanged);
    }   
    super.dispose();
  }

  // 🚀 MEJORA: Verificación de mounted
  void _onFocusChange() {
    if (!mounted) return;
    
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  // 🚀 MEJORA: Verificación de mounted
  void _onTextChanged() {
    if (!mounted) return;
    
    final hasText = widget.controller!.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }

    if (widget.enableRealTimeValidation &&
        widget.showValidationIndicator &&
        hasText) {
      _startValidation();
    } else if (!widget.enableRealTimeValidation || !hasText) {
      _validationManager.clearValidation();
    }
  }

  void _startValidation() {
    if (!mounted) return;

    final value = widget.controller?.text ?? '';
    _validationManager.startValidation(
      value,
      widget.fieldType,
      widget.validationDelay,
      widget.validator,
      widget.asyncValidator,
      widget.country,
    );
  }

  Future<bool> validateManually() async {
    if (!widget.enableRealTimeValidation) {
      _startValidation();
      // Esperar un poco para que se complete la validación
      await Future.delayed(widget.validationDelay);
      return _validationManager.state.value is ValidationValid;
    }
    return _validationManager.state.value is ValidationValid;
  }

  // Métodos públicos para obtener valores
  double get currencyValue {
    if (widget.fieldType != FieldType.currency) return 0.0;
    final value = widget.controller?.text ?? '';
    return CurrencyUtils.parseToDouble(value);
  }

  String get currencyValueAsString {
    if (widget.fieldType != FieldType.currency) return '';
    final value = widget.controller?.text ?? '';
    return CurrencyUtils.extractNumericValue(value, widget.currencySymbol);
  }

  void setCurrencyValue(double value) {
    if (widget.fieldType != FieldType.currency) return;
    final formatted = value.toStringAsFixed(2);
    widget.controller?.text = formatted;
  }

  String get phoneValue {
    if (widget.fieldType != FieldType.phone) return '';
    final value = widget.controller?.text ?? '';
    return PhoneUtils.getPhoneForDatabase(value, widget.country);
  }

  void setPhoneValue(String phoneNumber) {
    if (widget.fieldType != FieldType.phone) return;
    final formatted = PhoneUtils.formatFromDatabase(
      phoneNumber,
      widget.country,
    );
    widget.controller?.text = formatted;
  }

  // 🚀 MEJORA: Cache más inteligente para keyboard type
  TextInputType _getCachedKeyboardType() {
    return _cachedKeyboardType ??= _getKeyboardType();
  }

  TextInputType _getKeyboardType() {
    switch (widget.fieldType) {
      case FieldType.email:
        return TextInputType.emailAddress;
      case FieldType.phone:
        return TextInputType.phone;
      case FieldType.currency:
        return const TextInputType.numberWithOptions(decimal: true);
      case FieldType.url:
        return TextInputType.url;
      case FieldType.dni:
      case FieldType.ruc:
        return TextInputType.number;
      default:
        return widget.keyboardType;
    }
  }

  // 🚀 MEJORA: Cache mejorado para formatters
  List<TextInputFormatter> _getCachedInputFormatters() {
    final currentType = widget.fieldType.toString();
    if (_formattersCache == null || _lastFieldTypeString != currentType) {
      _formattersCache = _getInputFormatters();
      _lastFieldTypeString = currentType;
    }
    return _formattersCache!;
  }

  List<TextInputFormatter> _getInputFormatters() {
    List<TextInputFormatter> formatters = widget.inputFormatters ?? [];

    switch (widget.fieldType) {
      case FieldType.phone:
        formatters.insert(0, PhoneFormatterDynamic.fromCountry(widget.country));
        break;
      case FieldType.currency:
        formatters.insert(0, CurrencyFormatter(symbol: widget.currencySymbol));
        break;
      case FieldType.email:
        formatters.add(FilteringTextInputFormatter.deny(RegExp(r'\s')));
        break;
      case FieldType.dni:
        formatters.insert(0, DniFormatter());
        break;
      case FieldType.ruc:
        formatters.insert(0, RucFormatter());
        break;
      default:
        break;
    }

    return formatters;
  }

  Widget? _getCachedPrefixIcon() {
    return _cachedPrefixIcon ??= _getPrefixIcon();
  }

  Widget? _getPrefixIcon() {
    if (widget.prefixIcon != null) {
      return _buildIconWrapper(widget.prefixIcon!);
    }

    IconData? icon;
    switch (widget.fieldType) {
      case FieldType.email:
        icon = Icons.email_outlined;
        break;
      case FieldType.phone:
        icon = Icons.phone_outlined;
        break;
      case FieldType.currency:
        icon = Icons.attach_money_outlined;
        break;
      case FieldType.url:
        icon = Icons.link_outlined;
        break;
      case FieldType.dni:
        icon = Icons.badge_outlined;
        break;
      case FieldType.ruc:
        icon = Icons.business_outlined;
        break;
      case FieldType.password:
        icon = Icons.lock_outlined;
        break;
      default:
        return null;
    }

    return _buildIconWrapper(Icon(icon));
  }

  String? _getCachedPrefixText() {
    return _cachedPrefixText ??= _getPrefixText();
  }

  String? _getPrefixText() {
    if (widget.prefixText != null) return widget.prefixText;

    if (_isFocused) {
      switch (widget.fieldType) {
        case FieldType.currency:
          return '${widget.currencySymbol} ';
        case FieldType.phone:
          return '${widget.country.code} ';
        default:
          break;
      }
    }

    return null;
  }

  // 🚀 MEJORA: Optimizar contador con ValueListenableBuilder
  Widget _buildCharacterCounter() {
    if (widget.maxLength == null) return const SizedBox.shrink();
    
    return ValueListenableBuilder(
      valueListenable: widget.controller!,
      builder: (context, value, child) {
        return Positioned(
          right: 8,
          bottom: 1,
          child: Text(
            '${value.text.length}/${widget.maxLength}',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        );
      },
    );
  }

  // 🚀 MEJORA: Separar construcción del TextField
  Widget _buildTextField() {
    return Transform.scale(
      scale: _scaleAnimation.value,
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.filled
              ? widget.backgroundColor
              : Colors.transparent,
          borderRadius: _getCachedBorderRadius(),
          boxShadow: widget.filled ? getCachedShadows() : null,
          border: Border.all(
            color: _getCachedBorderColor(),
            width: widget.borderWidth ?? 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: _getCachedBorderRadius(),
          child: TextFormField(                
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: _getCachedKeyboardType(),
            obscureText: _isObscured,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: _getCachedInputFormatters(),
            textAlignVertical: TextAlignVertical.center,
            onChanged: (value) {
              widget.onChanged?.call(value);
            },
            onFieldSubmitted: widget.onSubmitted,
            validator: widget.enableRealTimeValidation
                ? null
                : widget.validator,
            style: _getCachedTextStyle(),
            decoration: InputDecoration(                  
              isDense: true,
              hintText: widget.hintText,
              prefixIcon: _getCachedPrefixIcon(),
              suffixIcon: _buildSuffixIcon(),
              prefixText: _getCachedPrefixText(),
              suffixText: widget.suffixText,
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

  @override
  Widget build(BuildContext context) {
    final showCounter = widget.maxLength != null && widget.controller != null;

    // 🚀 MEJORA: Usar RepaintBoundary para optimizar renders
    Widget textField = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => _buildTextField(),
      ),
    );

    if (showCounter) {
      return RepaintBoundary(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                textField,
                _buildCharacterCounter(),
              ],
            ),
            // 🚀 MEJORA: Error message optimizado
            _buildErrorMessage(),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(widget.label!, style: _getCachedLabelStyle()),
          ],
          textField,
          _buildErrorMessage(),
        ],
      ),
    );
  }

  // 🚀 MEJORA: Error message como widget separado
  Widget _buildErrorMessage() {
  if (!widget.enableRealTimeValidation) return const SizedBox.shrink();
  
  return ValueListenableBuilder<ValidationState>(
    valueListenable: _validationManager.state,
    builder: (context, state, child) {
      if (state is ValidationInvalid) {  // ← Usar 'is' en lugar de switch
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

  // 🚀 MÉTODOS CACHEADOS OPTIMIZADOS
  Color _getCachedBorderColor() {
    return _cachedBorderColor ??= _getBorderColor();
  }

  Color _getBorderColor() {
    return widget.borderColor ??
        (_isFocused
            ? CustomTextFieldConstants.defaultFocusedBorderColor
            : CustomTextFieldConstants.defaultBorderColor);
  }

  TextStyle _getCachedTextStyle() {
    return _cachedTextStyle ??=
        widget.textStyle ??
        TextStyle(
          color: widget.enabled ? AppColors.blue2 : AppColors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Oxygen-Regular'
        );
  }

  TextStyle _getCachedHintStyle() {
    return _cachedHintStyle ??=
        widget.hintStyle ??
        TextStyle(
          color: Colors.grey[500],
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 1.2,
        );
  }

  TextStyle _getCachedLabelStyle() {
    return _cachedLabelStyle ??=
        widget.labelStyle ??
        const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.blue,
        );
  }

  BorderRadius _getCachedBorderRadius() {
    return _cachedBorderRadius ??= BorderRadius.circular(widget.borderRadius);
  }

  EdgeInsetsGeometry _getCachedContentPadding() {
    return _cachedContentPadding ??=
        widget.contentPadding ?? _getDefaultContentPadding();
  }

  // 🚀 MEJORA: Lazy loading de sombras
  List<BoxShadow> getCachedShadows() {
    if (_shadowsCache == null || _lastFocusState != _isFocused) {
      _shadowsCache = _buildShadows();
      _lastFocusState = _isFocused;
    }
    return _shadowsCache!;
  }

  Widget _buildIconWrapper(Widget icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: IconTheme(
        data: IconThemeData(
          color:
              widget.colorIcon ??
              widget.borderColor ??
              (_isFocused ? const Color(0xFF666666) : Colors.grey[600]),
          size: 20,
        ),
        child: icon,
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    // 🚀 MEJORA: Usar ValueListenableBuilder para validation indicator
    if (widget.enableRealTimeValidation &&
        widget.showValidationIndicator &&
        _hasText) {
      Widget validationIcon = ValueListenableBuilder<ValidationState>(
        valueListenable: _validationManager.state,
        builder: (context, state, child) {
          return _buildValidationIndicator(state);
        },
      );

      if (widget.obscureText) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            validationIcon,
            const SizedBox(width: 4),
            _buildPasswordToggle(),
          ],
        );
      }

      return validationIcon;
    }

    if (widget.obscureText) {
      return _buildPasswordToggle();
    }

    if (widget.suffixIcon != null) {
      return _buildIconWrapper(widget.suffixIcon!);
    }

    return null;
  }

  Widget _buildPasswordToggle() {
    return IconButton(
      icon: Icon(
        _isObscured
            ? Icons.visibility_off_outlined
            : Icons.visibility_outlined,
      ),
      onPressed: () {
        setState(() {
          _isObscured = !_isObscured;
        });
      },
      color: _isFocused ? const Color(0xFF666666) : Colors.grey[600],
      iconSize: 20,
      splashRadius: 20,
      tooltip: _isObscured
          ? 'Mostrar contraseña'
          : 'Ocultar contraseña',
    );
  }

  // 🚀 MEJORA: Usar widgets constantes
  // Widget _buildValidationIndicator(ValidationState state) {
  //   switch (state.runtimeType) {
  //     case ValidationLoading:
  //       return const Padding(
  //         padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  //         child: CustomTextFieldConstants.loadingIndicator,
  //       );
  //     case ValidationValid:
  //       return Container(
  //         margin: const EdgeInsets.only(right: 12),
  //         child: CustomTextFieldConstants.validIcon,
  //       );
  //     case ValidationInvalid:
  //       return Container(
  //         margin: const EdgeInsets.only(right: 12),
  //         child: CustomTextFieldConstants.invalidIcon,
  //       );
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

  Widget _buildValidationIndicator(ValidationState state) {
  if (state is ValidationLoading) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: CustomTextFieldConstants.loadingIndicator,
    );
  }
  
  if (state is ValidationValid) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: CustomTextFieldConstants.validIcon,
    );
  }
  
  if (state is ValidationInvalid) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: CustomTextFieldConstants.invalidIcon,
    );
  }
  
  return const SizedBox.shrink();
}

  EdgeInsetsGeometry _getDefaultContentPadding() {
    if (widget.height != null) {
      double verticalPadding = (widget.height! - 20) / 2;
      verticalPadding = verticalPadding.clamp(8.0, 20.0);

      return EdgeInsets.symmetric(
        horizontal: (_getCachedPrefixIcon() != null) ? 12 : 16,
        vertical: verticalPadding,
      );
    }

    return EdgeInsets.symmetric(
      horizontal: (_getCachedPrefixIcon() != null) ? 12 : 16,
      vertical: widget.maxLines == 1 ? 14 : 12,
    );
  }

  List<BoxShadow> _buildShadows() {
    final double intensity = _shadowAnimation.value;
    final Color currentBorderColor = _getCachedBorderColor();
    Color shadowColor = _getCachedShadowColor(currentBorderColor);

    if (_isFocused) {
      return [
        BoxShadow(
          color: currentBorderColor.withValues(alpha: 0.3 + (intensity * 0.2)),
          offset: const Offset(0, 3),
          blurRadius: 4 + (intensity * 2),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.6),
          offset: const Offset(-1, -1),
          blurRadius: 2,
          spreadRadius: -1,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.18),
          offset: const Offset(4, 4),
          blurRadius: 8,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: currentBorderColor.withValues(alpha: 0.15),
          offset: const Offset(1, 1),
          blurRadius: 4,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.8),
          offset: const Offset(-2, -2),
          blurRadius: 4,
          spreadRadius: -1,
        ),
      ];
    }
  }

  Color _getCachedShadowColor(Color borderColor) {
    return _cachedShadowColor ??= _getShadowColorFromBorder(borderColor);
  }

  Color _getShadowColorFromBorder(Color borderColor) {
    if (borderColor == AppColors.blue ||
        borderColor == const Color(0xFF1976D2)) {
      return const Color(0xFF0D47A1);
    } else if (borderColor == Colors.red ||
        borderColor == const Color(0xFFD32F2F)) {
      return const Color(0xFF8D1E1E);
    } else if (borderColor == Colors.green ||
        borderColor == const Color(0xFF4CAF50)) {
      return const Color(0xFF1B5E20);
    } else if (borderColor == Colors.purple ||
        borderColor == const Color(0xFF9C27B0)) {
      return const Color(0xFF4A148C);
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

// 🚀 EXTENSIÓN PARA TextEditingController OPTIMIZADA
extension CustomTextFieldControllerExtension on TextEditingController {
  // Métodos para moneda mejorados
  double get currencyValue => CurrencyUtils.parseToDouble(text);
  String get currencyString => CurrencyUtils.extractNumericValue(text, 'S/');
  void setCurrencyValue(double value) =>
      text = CurrencyUtils.formatWithDecimals(value);
  bool get isValidCurrency => CurrencyUtils.isValidCurrency(text);

  String get currencyValueAsString =>
      CurrencyUtils.getValueAsString(currencyValue);
  void setCurrencyValueAsString(String value) => text = value;

  // Métodos para teléfono
  String phoneValue(CountryCode country) =>
      PhoneUtils.getPhoneForDatabase(text, country);
  void setPhoneValue(String phoneFromDB, CountryCode country) =>
      text = PhoneUtils.formatFromDatabase(phoneFromDB, country);
  bool isValidPhone(CountryCode country) =>
      PhoneUtils.isValidPhone(text, country);
  String get phoneDigits => text.replaceAll(RegExp(r'[^\d]'), '');

  // Métodos mejorados con enum
  String phoneValueEnhanced(CountryCode country) =>
      PhoneUtils.getPhoneForDatabase(text, country);
  void setPhoneValueEnhanced(String phoneFromDB, CountryCode country) =>
      text = PhoneUtils.formatFromDatabase(phoneFromDB, country);
  bool isValidPhoneEnhanced(CountryCode country) =>
      PhoneUtils.isValidPhone(text, country);
}

extension CountryCodeExtension on CountryCode {
  static CountryCode fromCode(String code) {
    switch (code) {
      case '+51':
        return CountryCode.peru;
      case '+57':
        return CountryCode.colombia;
      case '+593':
        return CountryCode.ecuador;
      case '+56':
        return CountryCode.chile;
      default:
        return CountryCode.peru; // Default
    }
  }
}

// 🚀 HELPERS PARA CREAR CAMPOS COMUNES FÁCILMENTE
class CustomTextFieldHelpers {
  /// Crea un campo de moneda con validaciones automáticas
  static CustomTextField currency({
    required String label,
    required TextEditingController controller,
    String? hintText,
    String currencySymbol = 'S/',
    double? minAmount,
    double? maxAmount,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
  }) {
    return CustomTextField(
      label: label,
      hintText: hintText ?? '0.00',
      controller: controller,
      fieldType: FieldType.currency,
      currencySymbol: currencySymbol,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: (value) => FieldValidators.validateCurrency(
        value,
        minAmount: minAmount,
        maxAmount: maxAmount,
      ),
      onChanged: onChanged,
    );
  }

  /// Crea un campo de teléfono con formato automático
  static CustomTextField phone({
    required String label,
    required TextEditingController controller,
    String? hintText,
    CountryCode country = CountryCode.peru,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
    TextStyle? labelStyle,
    bool? filled
  }) {
    return CustomTextField(
      label: label,
      filled: filled ?? true,
      labelStyle: labelStyle,
      hintText: hintText ?? 'Número de teléfono',
      controller: controller,
      fieldType: FieldType.phone,
      country: country,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: (value) =>
          FieldValidators.validatePhone(value, country: country),
      onChanged: onChanged,
    );
  }

  /// Crea un campo de email con validación estricta
  static CustomTextField email({
    required String label,
    TextStyle? labelStyle,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
  }) {
    return CustomTextField(
      label: label,
      labelStyle: labelStyle,
      hintText: hintText ?? 'correo@ejemplo.com',
      controller: controller,
      fieldType: FieldType.email,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: FieldValidators.validateEmail,
      onChanged: onChanged,
    );
  }

  /// Crea un campo de URL con validación
  static CustomTextField url({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
  }) {
    return CustomTextField(
      label: label,
      hintText: hintText ?? 'https://ejemplo.com',
      controller: controller,
      fieldType: FieldType.url,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: FieldValidators.validateUrl,
      onChanged: onChanged,
    );
  }

  /// Crea un campo de DNI con validación automática
  static CustomTextField dni({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
    TextStyle? labelStyle,
    TextStyle? hintStyle
  }) {
    return CustomTextField(
      label: label,
      labelStyle: labelStyle,
      hintText: '12345678',
      hintStyle: hintStyle,
      controller: controller,
      fieldType: FieldType.dni,
      maxLength: 8,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: FieldValidators.validateDni,
      onChanged: onChanged,
    );
  }

  /// Crea un campo de RUC con validación automática
  static CustomTextField ruc({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    bool enableRealTimeValidation = true,
  }) {
    return CustomTextField(
      label: label,
      hintText: hintText ?? '12345678901',
      controller: controller,
      fieldType: FieldType.ruc,
      maxLength: 11,
      borderColor: borderColor,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: FieldValidators.validateRuc,
      onChanged: onChanged,
    );
  }

  /// Crea un campo de texto normal con opciones comunes
  static CustomTextField text({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool obscureText = false,
    int maxLines = 1,
    int? maxLength,
    bool enableRealTimeValidation = true,
  }) {
    return CustomTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      fieldType: FieldType.text,
      borderColor: borderColor,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enableRealTimeValidation: enableRealTimeValidation,
      validator: validator,
      onChanged: onChanged,
    );
  }

  /// Crea un campo de contraseña con toggle de visibilidad
  static CustomTextField password({
    required String label,
    required TextEditingController controller,
    String? hintText,
    Color? borderColor,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    bool enableRealTimeValidation = false,
    TextStyle? labelStyle,
  }) {
    return CustomTextField(
      label: label,
      hintText: hintText ?? 'Ingresa tu contraseña',
      controller: controller,
      fieldType: FieldType.password,
      borderColor: borderColor,
      obscureText: true,
      labelStyle: labelStyle,
      enableRealTimeValidation: enableRealTimeValidation,
      // validator:
      //     validator ??
      //     (value) {
      //       if (value == null || value.isEmpty) return 'Campo requerido';
      //       if (value.length < 6) return 'Mínimo 6 caracteres';
      //       return null;
      //     },
      onChanged: onChanged,
    );
  }
}
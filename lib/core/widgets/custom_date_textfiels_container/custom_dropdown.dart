import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// Enum para tipos de dropdown
enum DropdownStyle {
  standard,    // Dropdown estándar
  searchable,  // Con búsqueda
  multiSelect, // Selección múltiple
}

// Clase para items del dropdown
class DropdownItem<T> {
  final T value;
  final String label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;

  const DropdownItem({
    required this.value,
    required this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropdownItem &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class CustomDropdown<T> extends StatefulWidget {
  final String? label;
  final String? hintText;
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
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
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final DropdownStyle dropdownStyle;
  final int? maxHeight;
  final bool showSearchBox;
  
  // Para multi-select
  final List<T>? selectedValues;
  final void Function(List<T>)? onMultiChanged;
  
  const CustomDropdown({
    super.key,
    this.label,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.backgroundColor = AppColors.white,
    this.borderColor,
    this.borderRadius = 6.0,
    this.contentPadding,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.filled = true,
    this.focusNode,
    this.height = 40,
    this.borderWidth = 0.5,
    this.prefixIcon,
    this.suffixIcon,
    this.dropdownStyle = DropdownStyle.standard,
    this.maxHeight,
    this.showSearchBox = false,
    this.selectedValues,
    this.onMultiChanged,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  bool _isExpanded = false;
  T? _selectedValue;
  List<T> _selectedMultiValues = [];
  List<DropdownItem<T>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _shadowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _selectedMultiValues = widget.selectedValues ?? [];
    _filteredItems = widget.items;
    
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shadowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.focusNode == null) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode.dispose();
    }
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_isFocused) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _filterItems() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items
          .where((item) => item.label.toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _showOverlay();
      _animationController.forward();
    } else {
      _removeOverlay();
      _animationController.reverse();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: widget.maxHeight?.toDouble() ?? 300,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: widget.borderColor ?? const Color(0xFFE0E0E0),
                  width: widget.borderWidth ?? 0.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSearchBox || widget.dropdownStyle == DropdownStyle.searchable) ...[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        final isSelected = widget.dropdownStyle == DropdownStyle.multiSelect
                            ? _selectedMultiValues.contains(item.value)
                            : _selectedValue == item.value;

                        return InkWell(
                          onTap: item.enabled
                              ? () => _onItemSelected(item.value)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (widget.borderColor ?? AppColors.blue)
                                      .withOpacity(0.1)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                if (widget.dropdownStyle == DropdownStyle.multiSelect)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check_box
                                          : Icons.check_box_outline_blank,
                                      size: 20,
                                      color: isSelected
                                          ? widget.borderColor ?? AppColors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                if (item.leading != null) ...[
                                  item.leading!,
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: item.enabled
                                          ? (isSelected
                                              ? widget.borderColor ?? AppColors.blue
                                              : Colors.black87)
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                                if (item.trailing != null) item.trailing!,
                                if (isSelected && widget.dropdownStyle == DropdownStyle.standard)
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color: widget.borderColor ?? AppColors.blue,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemSelected(T value) {
    if (widget.dropdownStyle == DropdownStyle.multiSelect) {
      setState(() {
        if (_selectedMultiValues.contains(value)) {
          _selectedMultiValues.remove(value);
        } else {
          _selectedMultiValues.add(value);
        }
      });
      widget.onMultiChanged?.call(_selectedMultiValues);
    } else {
      setState(() {
        _selectedValue = value;
        _isExpanded = false;
      });
      widget.onChanged?.call(value);
      _removeOverlay();
      _animationController.reverse();
    }
  }

  String _getDisplayText() {
    if (widget.dropdownStyle == DropdownStyle.multiSelect) {
      if (_selectedMultiValues.isEmpty) {
        return widget.hintText ?? 'Seleccionar';
      }
      final labels = _selectedMultiValues
          .map((v) => widget.items.firstWhere((item) => item.value == v).label)
          .join(', ');
      return labels;
    } else {
      if (_selectedValue == null) {
        return widget.hintText ?? 'Seleccionar';
      }
      return widget.items
          .firstWhere((item) => item.value == _selectedValue)
          .label;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue,
                ),
          ),
          const SizedBox(height: 2),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    color: widget.filled
                        ? widget.backgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    boxShadow: widget.filled ? _buildShadows() : null,
                    border: Border.all(
                      color: _getBorderColor(),
                      width: widget.borderWidth ?? 0.5,
                    ),
                  ),
                  child: InkWell(
                    onTap: _toggleDropdown,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Padding(
                      padding: widget.contentPadding ??
                          const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                      child: Row(
                        children: [
                          if (widget.prefixIcon != null) ...[
                            widget.prefixIcon!,
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              _getDisplayText(),
                              style: widget.textStyle ??
                                  TextStyle(
                                    color: widget.enabled
                                        ? (_selectedValue != null || _selectedMultiValues.isNotEmpty
                                            ? Colors.black87
                                            : Colors.grey[500])
                                        : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          RotationTransition(
                            turns: _rotationAnimation,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: _isFocused || _isExpanded
                                  ? const Color(0xFF666666)
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getBorderColor() {
    return widget.borderColor ??
        (_isFocused || _isExpanded
            ? const Color(0xFFE0E0E0)
            : const Color(0xFFF0F0F0));
  }

  List<BoxShadow> _buildShadows() {
    final double intensity = _shadowAnimation.value;
    final Color currentBorderColor = _getBorderColor();
    Color shadowColor = _getShadowColorFromBorder(currentBorderColor);

    if (_isFocused || _isExpanded) {
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

// Helpers para crear dropdowns comunes
class CustomDropdownHelpers {
  static CustomDropdown<T> standard<T>({
    required String label,
    required List<DropdownItem<T>> items,
    T? value,
    void Function(T?)? onChanged,
    Color? borderColor,
    String? hintText,
  }) {
    return CustomDropdown<T>(
      label: label,
      items: items,
      value: value,
      onChanged: onChanged,
      borderColor: borderColor,
      hintText: hintText,
    );
  }

  static CustomDropdown<T> searchable<T>({
    required String label,
    required List<DropdownItem<T>> items,
    T? value,
    void Function(T?)? onChanged,
    Color? borderColor,
    String? hintText,
  }) {
    return CustomDropdown<T>(
      label: label,
      items: items,
      value: value,
      onChanged: onChanged,
      borderColor: borderColor,
      hintText: hintText,
      dropdownStyle: DropdownStyle.searchable,
    );
  }

  static CustomDropdown<T> multiSelect<T>({
    required String label,
    required List<DropdownItem<T>> items,
    List<T>? selectedValues,
    void Function(List<T>)? onMultiChanged,
    Color? borderColor,
    String? hintText,
  }) {
    return CustomDropdown<T>(
      label: label,
      items: items,
      selectedValues: selectedValues,
      onMultiChanged: onMultiChanged,
      borderColor: borderColor,
      hintText: hintText,
      dropdownStyle: DropdownStyle.multiSelect,
    );
  }
}
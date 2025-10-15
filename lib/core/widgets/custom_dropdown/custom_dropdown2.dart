import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Modelo base para items del dropdown
abstract class DropdownItem {
  int get id;
  String get displayText;
  String get code;
  bool get isActive;
}

/// Widget de Dropdown personalizado y reutilizable
class CustomDropdown2<T extends DropdownItem> extends StatefulWidget {
  final int? selectedId;
  final List<T> items;
  final String? label;
  final String hint;
  final String? errorText;
  final ValueChanged<int?>? onChanged;
  final bool isLoading;
  final bool showSearchBox;
  
  // Propiedades de estilo
  final double height;
  final double borderWidth;
  final Color borderColor;
  final Color errorBorderColor;
  final Color backgroundColor;
  final Color iconColor;
  final Color activeColor;
  final Color inactiveColor;
  final double borderRadius;
  final int? maxHeight;
  
  // Propiedades de texto
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? itemTextStyle;
  final TextStyle? selectedTextStyle;
  final TextStyle? codeTextStyle;
  final TextStyle? errorStyle;
  
  // Propiedades del avatar
  final double avatarRadius;
  final double avatarFontSize;
  
  // Propiedades del ícono
  final IconData dropdownIcon;
  final double dropdownIconSize;

  const CustomDropdown2({
    super.key,
    required this.items,
    required this.hint,
    this.selectedId,
    this.label,
    this.errorText,
    this.onChanged,
    this.isLoading = false,
    this.showSearchBox = false,
    this.height = 35,
    this.borderWidth = 0.5,
    this.borderColor = const Color(0xFF2196F3),
    this.errorBorderColor = Colors.red,
    this.backgroundColor = Colors.white,
    this.iconColor = const Color(0xFF2196F3),
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.red,
    this.borderRadius = 6,
    this.maxHeight = 300,
    this.labelStyle,
    this.hintStyle,
    this.itemTextStyle,
    this.selectedTextStyle,
    this.codeTextStyle,
    this.errorStyle,
    this.avatarRadius = 10,
    this.avatarFontSize = 8,
    this.dropdownIcon = Icons.keyboard_arrow_down,
    this.dropdownIconSize = 20,
  });

  @override
  State<CustomDropdown2<T>> createState() => _CustomDropdown2State<T>();
}

class _CustomDropdown2State<T extends DropdownItem> extends State<CustomDropdown2<T>>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  T? _selectedItem;
  List<T> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _updateSelectedItem();
    _filteredItems = widget.items;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
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
  void didUpdateWidget(CustomDropdown2<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _updateSelectedItem();
    }
    if (oldWidget.items != widget.items) {
      _filteredItems = widget.items;
    }
  }

  void _updateSelectedItem() {
    if (widget.selectedId != null) {
      try {
        _selectedItem = widget.items.firstWhere((item) => item.id == widget.selectedId);
      } catch (e) {
        _selectedItem = null;
      }
    } else {
      _selectedItem = null;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items.where((item) {
        return item.displayText.toLowerCase().contains(query) ||
               item.code.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleDropdown() {
    if (widget.isLoading) return;

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
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _toggleDropdown();
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: const Offset(0.0, 40),
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
                        color: widget.borderColor,
                        width: widget.borderWidth,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.showSearchBox) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Buscar...',
                                hintStyle: TextStyle(
                                  fontSize: 9,
                                  fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
                                ),
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
                              style: TextStyle(
                                fontSize: 10,
                                fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                        ],
                        Flexible(
                          child: _filteredItems.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _filteredItems[index];
                                    final isSelected = _selectedItem?.id == item.id;

                                    return InkWell(
                                      onTap: () => _onItemSelected(item),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? widget.borderColor.withValues(alpha: 0.1)
                                              : null,
                                        ),
                                        child: Row(
                                          children: [
                                            // Avatar circular
                                            CircleAvatar(
                                              radius: widget.avatarRadius,
                                              backgroundColor: item.isActive
                                                  ? widget.activeColor
                                                  : widget.inactiveColor,
                                              child: Text(
                                                item.code.isNotEmpty
                                                    ? item.code.substring(0, 1).toUpperCase()
                                                    : '?',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: widget.avatarFontSize,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),

                                            // Texto principal
                                            Expanded(
                                              child: Text(
                                                item.displayText,
                                                style: widget.itemTextStyle ??
                                                    TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                      color: isSelected
                                                          ? widget.borderColor
                                                          : Colors.black87,
                                                      fontFamily: AppFonts.getFontFamily(
                                                        AppFont.oxygenRegular,
                                                      ),
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),

                                            const SizedBox(width: 8),

                                            // Código a la derecha
                                            Text(
                                              item.code,
                                              style: widget.codeTextStyle ??
                                                  TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[600],
                                                    fontFamily: AppFonts.getFontFamily(
                                                      AppFont.oxygenBold,
                                                    ),
                                                  ),
                                            ),

                                            // Icono de check si está seleccionado
                                            if (isSelected)
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8),
                                                child: Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: widget.borderColor,
                                                ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
          ),
        ),
      ),
    );
  }

  void _onItemSelected(T item) {
    setState(() {
      _selectedItem = item;
      _isExpanded = false;
    });
    widget.onChanged?.call(item.id);
    _removeOverlay();
    _animationController.reverse();
    _searchController.clear();
  }

  String _getDisplayText() {
    if (_selectedItem == null) {
      return widget.hint;
    }
    return _selectedItem!.displayText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                TextStyle(
                  fontSize: 9,
                  color: AppColors.blue3,
                  fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
                ),
          ),
          const SizedBox(height: 2),
        ],

        // Dropdown Container
        CompositedTransformTarget(
          link: _layerLink,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: widget.errorText != null
                    ? widget.errorBorderColor
                    : widget.borderColor,
                width: widget.borderWidth,
              ),
            ),
            child: widget.isLoading
                ? _buildLoadingIndicator()
                : InkWell(
                    onTap: _toggleDropdown,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          // Avatar si hay selección
                          if (_selectedItem != null) ...[
                            CircleAvatar(
                              radius: widget.avatarRadius,
                              backgroundColor: _selectedItem!.isActive
                                  ? widget.activeColor
                                  : widget.inactiveColor,
                              child: Text(
                                _selectedItem!.code.isNotEmpty
                                    ? _selectedItem!.code.substring(0, 1).toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.avatarFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Texto seleccionado o hint
                          Expanded(
                            child: Text(
                              _getDisplayText(),
                              style: _selectedItem == null
                                  ? (widget.hintStyle ??
                                      TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 10,
                                        fontFamily: AppFonts.getFontFamily(
                                          AppFont.oxygenRegular,
                                        ),
                                      ))
                                  : (widget.selectedTextStyle ??
                                      TextStyle(
                                        color: AppColors.blue2,
                                        fontSize: 10,
                                        fontFamily: AppFonts.getFontFamily(
                                          AppFont.oxygenBold,
                                        ),
                                      )),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Código si hay selección
                          if (_selectedItem != null) ...[
                            Text(
                              _selectedItem!.code,
                              style: widget.codeTextStyle ??
                                  TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                    fontFamily: AppFonts.getFontFamily(
                                      AppFont.oxygenBold,
                                    ),
                                  ),
                            ),
                            const SizedBox(width: 8),
                          ],

                          // Icono de flecha
                          RotationTransition(
                            turns: _rotationAnimation,
                            child: Icon(
                              widget.dropdownIcon,
                              color: _isExpanded ? widget.iconColor : Colors.grey[600],
                              size: widget.dropdownIconSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),

        // Error Text
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              widget.errorText!,
              style: widget.errorStyle ??
                  TextStyle(
                    color: Colors.red,
                    fontSize: 8,
                    fontFamily: AppFonts.getFontFamily(AppFont.oxygenRegular),
                  ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/domain/models/user_selection.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/widgets/user_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSelectorField extends StatefulWidget {
  /// Filtro de rol (ej: 'CONDUCTOR', 'ADMIN', null = todos)
  final String? roleFilter;
  
  /// Label del campo
  final String label;
  
  /// Hint text cuando no hay usuario seleccionado
  final String hintText;
  
  /// Si el campo es requerido
  final bool isRequired;
  
  /// Callback cuando se selecciona un usuario
  final Function(UserSelection) onUserSelected;
  
  /// Usuario seleccionado inicialmente (opcional)
  final UserSelection? initialUser;
  
  /// Permite limpiar la selección
  final bool allowClear;
  
  /// Color del borde
  final Color? borderColor;
  
  /// Altura del campo
  final double? height;

  const UserSelectorField({
    super.key,
    this.roleFilter,
    required this.label,
    this.hintText = 'Seleccionar usuario',
    this.isRequired = false,
    required this.onUserSelected,
    this.initialUser,
    this.allowClear = true,
    this.borderColor,
    this.height,
  });

  @override
  State<UserSelectorField> createState() => _UserSelectorFieldState();
}

class _UserSelectorFieldState extends State<UserSelectorField> {
  UserSelection? _selectedUser;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    if (widget.initialUser != null) {
      _selectedUser = widget.initialUser;
      _controller.text = _selectedUser!.nombreCompleto;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showUserSearchDialog() async {
    // Usar el UserBloc existente del contexto padre
    final result = await showDialog<UserSelection>(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<UserBloc>(),
        child: UserSearchDialog(
          roleFilter: widget.roleFilter,
          title: widget.roleFilter != null
              ? 'Buscar ${widget.roleFilter}'
              : 'Buscar Usuario',
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedUser = result;
        _controller.text = result.nombreCompleto;
      });
      widget.onUserSelected(result);
    }
  }

  // void _clearSelection() {
  //   setState(() {
  //     _selectedUser = null;
  //     _controller.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo usando CustomTextField
        GestureDetector(
          onTap: _showUserSearchDialog,
          child: AbsorbPointer(
            child: CustomTextField(
              label: widget.isRequired ? '${widget.label} *' : widget.label,
              hintText: widget.hintText,
              controller: _controller,
              enabled: true,
              height: widget.height,
              borderColor: widget.borderColor ?? AppColors.blue3,
              backgroundColor: _selectedUser != null 
                  ? AppColors.blue3.withValues(alpha: 0.05)
                  : Colors.white,
              // prefixIcon: Icon(
              //   Icons.person_outline_rounded,
              //   color: _selectedUser != null 
              //       ? AppColors.blue3 
              //       : Colors.grey.shade400,
              //   size: 20,
              // ),
              prefixIcon: Icon(Icons.person_outline_rounded),
              // suffixIcon: _selectedUser != null && widget.allowClear
              //     ? IconButton(
              //         icon: Icon(
              //           Icons.clear_rounded,
              //           color: Colors.grey.shade600,
              //           size: 18,
              //         ),
              //         onPressed: _clearSelection,
              //         padding: EdgeInsets.zero,
              //         constraints: const BoxConstraints(),
              //       )
              //     : Icon(
              //         Icons.arrow_drop_down_rounded,
              //         color: Colors.grey.shade600,
              //         size: 22,
              //       ),
              suffixIcon: Icon(Icons.arrow_drop_down,size: 20,),
              validator: widget.isRequired
                  ? (value) {
                      if (_selectedUser == null || value == null || value.isEmpty) {
                        return 'Debe seleccionar un usuario';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ),
        
        // Información adicional del usuario seleccionado
        if (_selectedUser != null)
          Padding(
            padding: const EdgeInsets.only(top: 6,left: 0),
            child: Container(
              // padding: const EdgeInsets.symmetric(
              //   horizontal: 8,
              //   vertical: 4,
              // ),
              // decoration: BoxDecoration(
              //   color: AppColors.blue3.withValues(alpha: 0.1),
              //   borderRadius: BorderRadius.circular(4),
              //   border: Border.all(
              //     color: AppColors.blue3.withValues(alpha: 0.3),
              //     width: 1,
              //   ),
              // ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.blue3,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${_selectedUser!.id}',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.blue3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_selectedUser!.dni != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '• DNI: ${_selectedUser!.dni}',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.blue3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
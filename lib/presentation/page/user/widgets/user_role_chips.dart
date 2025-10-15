// lib/presentation/page/user/widgets/user_role_chips.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/roles.dart';
import 'package:consumo_combustible/domain/models/simple_role.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:flutter/material.dart';

class UserRoleChips extends StatelessWidget {
  final User user;
  final double fontSize;
  final double horizontalPadding;
  final double verticalPadding;
  final Color? chipColor;
  final Color? borderColor;
  final Color? textColor;

  const UserRoleChips({
    super.key,
    required this.user,
    this.fontSize = 8,
    this.horizontalPadding = 6,
    this.verticalPadding = 2,
    this.chipColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!user.hasRoles) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: _buildRoleChips(),
    );
  }

  List<Widget> _buildRoleChips() {
    final roles = user.rolesAsList;

    return roles.map((rol) {
      final roleName = _getRoleName(rol);
      
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          color: chipColor ?? AppColors.blue3.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: borderColor ?? AppColors.blue3.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: AppSubtitle(roleName,fontSize: 7,),
      );
    }).toList();
  }

  String _getRoleName(dynamic rol) {
    if (rol is SimpleRole) {
      return rol.nombre;
    } else if (rol is Rol) {
      return rol.nombre;
    }
    return 'ROL';
  }
}
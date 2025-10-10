// ✅ lib/presentation/page/user/widgets/user_list_item.dart
// Widget compacto para mostrar usuarios en el dialog de selección

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  final User user;
  final VoidCallback onTap;
  final bool showRoles;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    this.showRoles = true,
  });

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = '${user.nombres} ${user.apellidos}'.trim();
    
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Avatar con iniciales
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.blue3.withValues(alpha: 0.1),
                child: Text(
                  _getInitials(nombreCompleto),
                  style: TextStyle(
                    color: AppColors.blue3,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre completo
                    Text(
                      nombreCompleto,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // DNI y roles
                    Row(
                      children: [
                        // DNI
                        Container(
                          padding: const EdgeInsets.symmetric(
                            // horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'DNI: ${user.dni}',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        
                        // Roles (si showRoles es true)
                        if (showRoles && user.hasRoles) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: _buildRolesChips(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Icono de selección
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construir chips de roles
  Widget _buildRolesChips() {
    List<String> roleNames = [];
    
    // Extraer nombres de roles según el tipo
    if (user.roles is List) {
      final roles = user.roles as List;
      if (roles.isNotEmpty) {
        roleNames = roles.map((role) {
          if (role.nombre != null) {
            return role.nombre as String;
          }
          return '';
        }).where((name) => name.isNotEmpty).take(2).toList();
      }
    }

    if (roleNames.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      children: roleNames.map((roleName) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppColors.blue3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: AppColors.blue3.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            roleName,
            style: TextStyle(
              fontSize: 7,
              color: AppColors.blue3,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Obtener iniciales del nombre
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    // Primera letra del nombre y primer apellido
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }
}
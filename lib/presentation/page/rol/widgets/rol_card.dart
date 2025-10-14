// lib/presentation/page/roles/widgets/rol_card.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RolCard extends StatelessWidget {
  final Rol rol;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onActivar;

  const RolCard({
    super.key,
    required this.rol,
    required this.onTap,
    required this.onDelete,
    required this.onActivar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue3.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Nombre + Estado
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: AppColors.blue3,
                            size: 16,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppTitle(
                                  rol.nombre,
                                  fontSize: 12,
                                  color: AppColors.blue3,
                                ),
                                if (rol.descripcion != null &&
                                    rol.descripcion!.isNotEmpty)
                                  AppTitle(
                                    rol.descripcion!,
                                    fontSize: 10,
                                    color: AppColors.blue3.withValues(alpha: 0.7),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 5),

                // Divider
                Divider(color: AppColors.blue3.withValues(alpha: 0.1)),
                const SizedBox(height: 5),

                // Información de permisos
                _buildPermisosResumen(),
                // const SizedBox(height: 5),

                // Footer: Usuarios + Fecha + Acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Usuarios asignados
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: AppColors.blue3.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        AppTitle(
                          '${rol.usuariosCount} usuario${rol.usuariosCount != 1 ? 's' : ''}',
                          fontSize: 12,
                          color: AppColors.blue3.withValues(alpha: 0.7),
                        ),
                      ],
                    ),

                    // Fecha de creación
                    AppTitle(
                      DateFormat('dd/MM/yyyy').format(rol.createdAt),
                      fontSize: 12,
                      color: AppColors.blue3.withValues(alpha: 0.7),
                    ),

                    // Acciones
                    _buildActions(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rol.activo
            ? AppColors.green.withValues(alpha: 0.1)
            : AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: rol.activo ? AppColors.green : AppColors.red,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            rol.activo ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: rol.activo ? AppColors.green : AppColors.red,
          ),
          const SizedBox(width: 4),
          AppTitle(
            rol.activo ? 'Activo' : 'Inactivo',
            fontSize: 9,
            color: rol.activo ? AppColors.green : AppColors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildPermisosResumen() {
    // Contar permisos activos por categoría
    final permisos = rol.permisos;
    final categorias = <String, int>{};

    // Usuarios
    final usuariosActivos = [
      permisos.usuarios.crear,
      permisos.usuarios.leer,
      permisos.usuarios.actualizar,
      permisos.usuarios.eliminar,
    ].where((p) => p).length;
    if (usuariosActivos > 0) categorias['Usuarios'] = usuariosActivos;

    // Unidades
    final unidadesActivos = [
      permisos.unidades.crear,
      permisos.unidades.leer,
      permisos.unidades.actualizar,
      permisos.unidades.eliminar,
      permisos.unidades.asignarConductor,
    ].where((p) => p).length;
    if (unidadesActivos > 0) categorias['Unidades'] = unidadesActivos;

    // Abastecimientos
    final abastecimientosActivos = [
      permisos.abastecimientos.crear,
      permisos.abastecimientos.leer,
      permisos.abastecimientos.actualizar,
      permisos.abastecimientos.eliminar,
      permisos.abastecimientos.aprobar,
      permisos.abastecimientos.rechazar,
    ].where((p) => p).length;
    if (abastecimientosActivos > 0) {
      categorias['Abastecimientos'] = abastecimientosActivos;
    }

    // Mantenimientos
    final mantenimientosActivos = [
      permisos.mantenimientos.crear,
      permisos.mantenimientos.leer,
      permisos.mantenimientos.actualizar,
      permisos.mantenimientos.programar,
    ].where((p) => p).length;
    if (mantenimientosActivos > 0) {
      categorias['Mantenimientos'] = mantenimientosActivos;
    }

    // Fallas
    final fallasActivos = [
      permisos.fallas.crear,
      permisos.fallas.leer,
      permisos.fallas.actualizar,
      permisos.fallas.programar,
    ].where((p) => p).length;
    if (fallasActivos > 0) categorias['Fallas'] = fallasActivos;

    // Reportes
    final reportesActivos = [
      permisos.reportes.ver,
      permisos.reportes.exportar,
      permisos.reportes.configurar,
    ].where((p) => p).length;
    if (reportesActivos > 0) categorias['Reportes'] = reportesActivos;

    // Administrativo
    final adminActivos = [
      permisos.administrativo.configurarSistema,
      permisos.administrativo.gestionarRoles,
      permisos.administrativo.verAuditoria,
    ].where((p) => p).length;
    if (adminActivos > 0) categorias['Admin'] = adminActivos;

    if (categorias.isEmpty) {
      return AppTitle(
        'Sin permisos asignados',
        fontSize: 10,
        color: AppColors.red.withValues(alpha: 0.7),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categorias.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.blue3.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppTitle(
            '${entry.key} (${entry.value})',
            fontSize: 9,
            color: AppColors.blue3,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.white,
      icon: Icon(
        Icons.more_vert,
        color: AppColors.blue3,
        size: 16,
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onTap();
            break;
          case 'delete':
            if (rol.activo) {
              onDelete();
            }
            break;
          case 'activate':
            if (!rol.activo) {
              onActivar();
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 18, color: AppColors.blue3),
              const SizedBox(width: 8),
              AppTitle(
                'Editar',
                fontSize: 10,
                color: AppColors.blue3,
              ),
            ],
          ),
        ),
        if (rol.activo)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, size: 18, color: AppColors.red),
                const SizedBox(width: 8),
                AppTitle(
                  'Desactivar',
                  fontSize: 10,
                  color: AppColors.red,
                ),
              ],
            ),
          ),
        if (!rol.activo)
          PopupMenuItem(
            value: 'activate',
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppColors.green),
                const SizedBox(width: 8),
                AppTitle(
                  'Activar',
                  fontSize: 10,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
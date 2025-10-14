// lib/presentation/page/roles/widgets/permisos_section.dart

import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:flutter/material.dart';

class PermisosSection extends StatefulWidget {
  final Permisos permisos;
  final ValueChanged<Permisos> onPermisosChanged;

  const PermisosSection({
    super.key,
    required this.permisos,
    required this.onPermisosChanged,
  });

  @override
  State<PermisosSection> createState() => _PermisosSectionState();
}

class _PermisosSectionState extends State<PermisosSection> {
  final Map<String, bool> _expandedSections = {
    'usuarios': true,
    'unidades': false,
    'abastecimientos': false,
    'mantenimientos': false,
    'fallas': false,
    'reportes': false,
    'administrativo': false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildUsuariosSection(),
        _buildDivider(),
        _buildUnidadesSection(),
        _buildDivider(),
        _buildAbastecimientosSection(),
        _buildDivider(),
        _buildMantenimientosSection(),
        _buildDivider(),
        _buildFallasSection(),
        _buildDivider(),
        _buildReportesSection(),
        _buildDivider(),
        _buildAdministrativoSection(),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.blue3.withValues(alpha: 0.1),
      height: 1,
    );
  }

  // === USUARIOS ===

  Widget _buildUsuariosSection() {
    final permisos = widget.permisos.usuarios;
    final isExpanded = _expandedSections['usuarios'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.people,
      title: 'Usuarios',
      subtitle: _getActivePermisosCount([
        permisos.crear,
        permisos.leer,
        permisos.actualizar,
        permisos.eliminar,
      ], 4),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['usuarios'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Crear usuarios',
          permisos.crear,
          (value) => _updateUsuarios(crear: value),
        ),
        _buildCheckboxTile(
          'Ver usuarios',
          permisos.leer,
          (value) => _updateUsuarios(leer: value),
        ),
        _buildCheckboxTile(
          'Actualizar usuarios',
          permisos.actualizar,
          (value) => _updateUsuarios(actualizar: value),
        ),
        _buildCheckboxTile(
          'Eliminar usuarios',
          permisos.eliminar,
          (value) => _updateUsuarios(eliminar: value),
        ),
      ],
    );
  }

  void _updateUsuarios({
    bool? crear,
    bool? leer,
    bool? actualizar,
    bool? eliminar,
  }) {
    final current = widget.permisos.usuarios;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        usuarios: PermisosUsuarios(
          crear: crear ?? current.crear,
          leer: leer ?? current.leer,
          actualizar: actualizar ?? current.actualizar,
          eliminar: eliminar ?? current.eliminar,
        ),
      ),
    );
  }

  // === UNIDADES ===

  Widget _buildUnidadesSection() {
    final permisos = widget.permisos.unidades;
    final isExpanded = _expandedSections['unidades'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.directions_car,
      title: 'Unidades',
      subtitle: _getActivePermisosCount([
        permisos.crear,
        permisos.leer,
        permisos.actualizar,
        permisos.eliminar,
        permisos.asignarConductor,
      ], 5),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['unidades'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Crear unidades',
          permisos.crear,
          (value) => _updateUnidades(crear: value),
        ),
        _buildCheckboxTile(
          'Ver unidades',
          permisos.leer,
          (value) => _updateUnidades(leer: value),
        ),
        _buildCheckboxTile(
          'Actualizar unidades',
          permisos.actualizar,
          (value) => _updateUnidades(actualizar: value),
        ),
        _buildCheckboxTile(
          'Eliminar unidades',
          permisos.eliminar,
          (value) => _updateUnidades(eliminar: value),
        ),
        _buildCheckboxTile(
          'Asignar conductor',
          permisos.asignarConductor,
          (value) => _updateUnidades(asignarConductor: value),
        ),
      ],
    );
  }

  void _updateUnidades({
    bool? crear,
    bool? leer,
    bool? actualizar,
    bool? eliminar,
    bool? asignarConductor,
  }) {
    final current = widget.permisos.unidades;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        unidades: PermisosUnidades(
          crear: crear ?? current.crear,
          leer: leer ?? current.leer,
          actualizar: actualizar ?? current.actualizar,
          eliminar: eliminar ?? current.eliminar,
          asignarConductor: asignarConductor ?? current.asignarConductor,
        ),
      ),
    );
  }

  // === ABASTECIMIENTOS ===

  Widget _buildAbastecimientosSection() {
    final permisos = widget.permisos.abastecimientos;
    final isExpanded = _expandedSections['abastecimientos'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.local_gas_station,
      title: 'Abastecimientos',
      subtitle: _getActivePermisosCount([
        permisos.crear,
        permisos.leer,
        permisos.actualizar,
        permisos.eliminar,
        permisos.aprobar,
        permisos.rechazar,
      ], 6),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['abastecimientos'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Crear tickets',
          permisos.crear,
          (value) => _updateAbastecimientos(crear: value),
        ),
        _buildCheckboxTile(
          'Ver tickets',
          permisos.leer,
          (value) => _updateAbastecimientos(leer: value),
        ),
        _buildCheckboxTile(
          'Actualizar tickets',
          permisos.actualizar,
          (value) => _updateAbastecimientos(actualizar: value),
        ),
        _buildCheckboxTile(
          'Eliminar tickets',
          permisos.eliminar,
          (value) => _updateAbastecimientos(eliminar: value),
        ),
        _buildCheckboxTile(
          'Aprobar tickets',
          permisos.aprobar,
          (value) => _updateAbastecimientos(aprobar: value),
        ),
        _buildCheckboxTile(
          'Rechazar tickets',
          permisos.rechazar,
          (value) => _updateAbastecimientos(rechazar: value),
        ),
      ],
    );
  }

  void _updateAbastecimientos({
    bool? crear,
    bool? leer,
    bool? actualizar,
    bool? eliminar,
    bool? aprobar,
    bool? rechazar,
  }) {
    final current = widget.permisos.abastecimientos;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        abastecimientos: PermisosAbastecimientos(
          crear: crear ?? current.crear,
          leer: leer ?? current.leer,
          actualizar: actualizar ?? current.actualizar,
          eliminar: eliminar ?? current.eliminar,
          aprobar: aprobar ?? current.aprobar,
          rechazar: rechazar ?? current.rechazar,
        ),
      ),
    );
  }

  // === MANTENIMIENTOS ===

  Widget _buildMantenimientosSection() {
    final permisos = widget.permisos.mantenimientos;
    final isExpanded = _expandedSections['mantenimientos'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.build,
      title: 'Mantenimientos',
      subtitle: _getActivePermisosCount([
        permisos.crear,
        permisos.leer,
        permisos.actualizar,
        permisos.programar,
      ], 4),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['mantenimientos'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Crear mantenimientos',
          permisos.crear,
          (value) => _updateMantenimientos(crear: value),
        ),
        _buildCheckboxTile(
          'Ver mantenimientos',
          permisos.leer,
          (value) => _updateMantenimientos(leer: value),
        ),
        _buildCheckboxTile(
          'Actualizar mantenimientos',
          permisos.actualizar,
          (value) => _updateMantenimientos(actualizar: value),
        ),
        _buildCheckboxTile(
          'Programar mantenimientos',
          permisos.programar,
          (value) => _updateMantenimientos(programar: value),
        ),
      ],
    );
  }

  void _updateMantenimientos({
    bool? crear,
    bool? leer,
    bool? actualizar,
    bool? programar,
  }) {
    final current = widget.permisos.mantenimientos;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        mantenimientos: PermisosMantenimientos(
          crear: crear ?? current.crear,
          leer: leer ?? current.leer,
          actualizar: actualizar ?? current.actualizar,
          programar: programar ?? current.programar,
        ),
      ),
    );
  }

  // === FALLAS ===

  Widget _buildFallasSection() {
    final permisos = widget.permisos.fallas;
    final isExpanded = _expandedSections['fallas'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.warning,
      title: 'Fallas',
      subtitle: _getActivePermisosCount([
        permisos.crear,
        permisos.leer,
        permisos.actualizar,
        permisos.programar,
      ], 4),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['fallas'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Reportar fallas',
          permisos.crear,
          (value) => _updateFallas(crear: value),
        ),
        _buildCheckboxTile(
          'Ver fallas',
          permisos.leer,
          (value) => _updateFallas(leer: value),
        ),
        _buildCheckboxTile(
          'Actualizar fallas',
          permisos.actualizar,
          (value) => _updateFallas(actualizar: value),
        ),
        _buildCheckboxTile(
          'Programar reparaciones',
          permisos.programar,
          (value) => _updateFallas(programar: value),
        ),
      ],
    );
  }

  void _updateFallas({
    bool? crear,
    bool? leer,
    bool? actualizar,
    bool? programar,
  }) {
    final current = widget.permisos.fallas;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        fallas: PermisosFallas(
          crear: crear ?? current.crear,
          leer: leer ?? current.leer,
          actualizar: actualizar ?? current.actualizar,
          programar: programar ?? current.programar,
        ),
      ),
    );
  }

  // === REPORTES ===

  Widget _buildReportesSection() {
    final permisos = widget.permisos.reportes;
    final isExpanded = _expandedSections['reportes'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.assessment,
      title: 'Reportes',
      subtitle: _getActivePermisosCount([
        permisos.ver,
        permisos.exportar,
        permisos.configurar,
      ], 3),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['reportes'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Ver reportes',
          permisos.ver,
          (value) => _updateReportes(ver: value),
        ),
        _buildCheckboxTile(
          'Exportar reportes',
          permisos.exportar,
          (value) => _updateReportes(exportar: value),
        ),
        _buildCheckboxTile(
          'Configurar reportes',
          permisos.configurar,
          (value) => _updateReportes(configurar: value),
        ),
      ],
    );
  }

  void _updateReportes({
    bool? ver,
    bool? exportar,
    bool? configurar,
  }) {
    final current = widget.permisos.reportes;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        reportes: PermisosReportes(
          ver: ver ?? current.ver,
          exportar: exportar ?? current.exportar,
          configurar: configurar ?? current.configurar,
        ),
      ),
    );
  }

  // === ADMINISTRATIVO ===

  Widget _buildAdministrativoSection() {
    final permisos = widget.permisos.administrativo;
    final isExpanded = _expandedSections['administrativo'] ?? false;

    return _buildPermisoCategory(
      icon: Icons.admin_panel_settings,
      title: 'Administrativo',
      subtitle: _getActivePermisosCount([
        permisos.configurarSistema,
        permisos.gestionarRoles,
        permisos.verAuditoria,
      ], 3),
      isExpanded: isExpanded,
      onExpanded: (value) {
        setState(() => _expandedSections['administrativo'] = value);
      },
      children: [
        _buildCheckboxTile(
          'Configurar sistema',
          permisos.configurarSistema,
          (value) => _updateAdministrativo(configurarSistema: value),
        ),
        _buildCheckboxTile(
          'Gestionar roles',
          permisos.gestionarRoles,
          (value) => _updateAdministrativo(gestionarRoles: value),
        ),
        _buildCheckboxTile(
          'Ver auditoría',
          permisos.verAuditoria,
          (value) => _updateAdministrativo(verAuditoria: value),
        ),
      ],
    );
  }

  void _updateAdministrativo({
    bool? configurarSistema,
    bool? gestionarRoles,
    bool? verAuditoria,
  }) {
    final current = widget.permisos.administrativo;
    widget.onPermisosChanged(
      widget.permisos.copyWith(
        administrativo: PermisosAdministrativo(
          configurarSistema: configurarSistema ?? current.configurarSistema,
          gestionarRoles: gestionarRoles ?? current.gestionarRoles,
          verAuditoria: verAuditoria ?? current.verAuditoria,
        ),
      ),
    );
  }

  // === HELPER WIDGETS ===

  Widget _buildPermisoCategory({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isExpanded,
    required ValueChanged<bool> onExpanded,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(        
        leading: Icon(icon, color: AppColors.blue3, size: 20),
        title: AppTitle(
          title,
          fontSize: 12,
          color: AppColors.blue3,
        ),
        subtitle: AppTitle(
          subtitle,
          fontSize: 10,
          color: AppColors.blue3.withValues(alpha: 0.7),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: AppColors.blue3,
          // size: 16,
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpanded,
        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
        dense: true,
        children: children,
      ),
    );
  }

  Widget _buildCheckboxTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SizedBox(
      height: 30,
      child: Transform.scale(
        scale: 0.80,
        child: CheckboxListTile(
          title: AppTitle(
            title,
            fontSize: 12,
            color: AppColors.blue3,
          ),
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: AppColors.blue3,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          contentPadding: const EdgeInsets.only(left: 30, right: 16),
        ),
      ),
    );
  }

  String _getActivePermisosCount(List<bool> permisos, int total) {
    final active = permisos.where((p) => p).length;
    return '$active de $total permisos activos';
  }
}

// Extension para copyWith en Permisos
extension PermisosExtension on Permisos {
  Permisos copyWith({
    PermisosUsuarios? usuarios,
    PermisosUnidades? unidades,
    PermisosAbastecimientos? abastecimientos,
    PermisosMantenimientos? mantenimientos,
    PermisosFallas? fallas,
    PermisosReportes? reportes,
    PermisosAdministrativo? administrativo,
  }) {
    return Permisos(
      usuarios: usuarios ?? this.usuarios,
      unidades: unidades ?? this.unidades,
      abastecimientos: abastecimientos ?? this.abastecimientos,
      mantenimientos: mantenimientos ?? this.mantenimientos,
      fallas: fallas ?? this.fallas,
      reportes: reportes ?? this.reportes,
      administrativo: administrativo ?? this.administrativo,
    );
  }
}
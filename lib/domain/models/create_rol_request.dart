// lib/domain/models/create_rol_request.dart

import 'package:consumo_combustible/domain/models/rol.dart';

class CreateRolRequest {
  final String nombre;
  final String? descripcion;
  final Permisos permisos;
  final bool activo;

  CreateRolRequest({
    required this.nombre,
    this.descripcion,
    required this.permisos,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'permisos': permisos.toJson(),
      'activo': activo,
    };
  }

  factory CreateRolRequest.fromJson(Map<String, dynamic> json) {
    return CreateRolRequest(
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      permisos: Permisos.fromJson(json['permisos'] ?? {}),
      activo: json['activo'] ?? true,
    );
  }

  // Factory constructor para crear un rol con permisos por defecto (todos en false)
  factory CreateRolRequest.empty({String nombre = '', String? descripcion}) {
    return CreateRolRequest(
      nombre: nombre,
      descripcion: descripcion,
      permisos: Permisos(
        usuarios: PermisosUsuarios(
          crear: false,
          leer: false,
          actualizar: false,
          eliminar: false,
        ),
        unidades: PermisosUnidades(
          crear: false,
          leer: false,
          actualizar: false,
          eliminar: false,
          asignarConductor: false,
        ),
        abastecimientos: PermisosAbastecimientos(
          crear: false,
          leer: false,
          actualizar: false,
          eliminar: false,
          aprobar: false,
          rechazar: false,
        ),
        mantenimientos: PermisosMantenimientos(
          crear: false,
          leer: false,
          actualizar: false,
          programar: false,
        ),
        fallas: PermisosFallas(
          crear: false,
          leer: false,
          actualizar: false,
          programar: false,
        ),
        reportes: PermisosReportes(
          ver: false,
          exportar: false,
          configurar: false,
        ),
        administrativo: PermisosAdministrativo(
          configurarSistema: false,
          gestionarRoles: false,
          verAuditoria: false,
        ),
      ),
      activo: true,
    );
  }

  // Método para copiar con nuevos valores
  CreateRolRequest copyWith({
    String? nombre,
    String? descripcion,
    Permisos? permisos,
    bool? activo,
  }) {
    return CreateRolRequest(
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      permisos: permisos ?? this.permisos,
      activo: activo ?? this.activo,
    );
  }
}
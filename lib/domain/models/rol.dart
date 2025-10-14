// lib/domain/models/rol.dart

class Rol {
  final int id;
  final String nombre;
  final String? descripcion;
  final Permisos permisos;
  final bool activo;
  final DateTime createdAt;
  final int usuariosCount;

  Rol({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.permisos,
    required this.activo,
    required this.createdAt,
    required this.usuariosCount,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      permisos: Permisos.fromJson(json['permisos'] ?? {}),
      activo: json['activo'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      usuariosCount: json['usuariosCount'] ?? 
                     json['_count']?['usuariosRoles'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'permisos': permisos.toJson(),
      'activo': activo,
      'createdAt': createdAt.toIso8601String(),
      'usuariosCount': usuariosCount,
    };
  }
}

// Modelo de respuesta paginada
class RolesResponse {
  final List<Rol> data;
  final int total;

  RolesResponse({
    required this.data,
    required this.total,
  });

  factory RolesResponse.fromJson(Map<String, dynamic> json) {
    return RolesResponse(
      data: (json['data'] as List?)
              ?.map((item) => Rol.fromJson(item))
              .toList() ??
          [],
      total: json['total'] ?? 0,
    );
  }
}

// Estructura de Permisos
class Permisos {
  final PermisosUsuarios usuarios;
  final PermisosUnidades unidades;
  final PermisosAbastecimientos abastecimientos;
  final PermisosMantenimientos mantenimientos;
  final PermisosFallas fallas;
  final PermisosReportes reportes;
  final PermisosAdministrativo administrativo;

  Permisos({
    required this.usuarios,
    required this.unidades,
    required this.abastecimientos,
    required this.mantenimientos,
    required this.fallas,
    required this.reportes,
    required this.administrativo,
  });

  factory Permisos.fromJson(Map<String, dynamic> json) {
    return Permisos(
      usuarios: PermisosUsuarios.fromJson(json['usuarios'] ?? {}),
      unidades: PermisosUnidades.fromJson(json['unidades'] ?? {}),
      abastecimientos: PermisosAbastecimientos.fromJson(json['abastecimientos'] ?? {}),
      mantenimientos: PermisosMantenimientos.fromJson(json['mantenimientos'] ?? {}),
      fallas: PermisosFallas.fromJson(json['fallas'] ?? {}),
      reportes: PermisosReportes.fromJson(json['reportes'] ?? {}),
      administrativo: PermisosAdministrativo.fromJson(json['administrativo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuarios': usuarios.toJson(),
      'unidades': unidades.toJson(),
      'abastecimientos': abastecimientos.toJson(),
      'mantenimientos': mantenimientos.toJson(),
      'fallas': fallas.toJson(),
      'reportes': reportes.toJson(),
      'administrativo': administrativo.toJson(),
    };
  }
}

class PermisosUsuarios {
  final bool crear;
  final bool leer;
  final bool actualizar;
  final bool eliminar;

  PermisosUsuarios({
    required this.crear,
    required this.leer,
    required this.actualizar,
    required this.eliminar,
  });

  factory PermisosUsuarios.fromJson(Map<String, dynamic> json) {
    return PermisosUsuarios(
      crear: json['crear'] ?? false,
      leer: json['leer'] ?? false,
      actualizar: json['actualizar'] ?? false,
      eliminar: json['eliminar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crear': crear,
      'leer': leer,
      'actualizar': actualizar,
      'eliminar': eliminar,
    };
  }
}

class PermisosUnidades {
  final bool crear;
  final bool leer;
  final bool actualizar;
  final bool eliminar;
  final bool asignarConductor;

  PermisosUnidades({
    required this.crear,
    required this.leer,
    required this.actualizar,
    required this.eliminar,
    required this.asignarConductor,
  });

  factory PermisosUnidades.fromJson(Map<String, dynamic> json) {
    return PermisosUnidades(
      crear: json['crear'] ?? false,
      leer: json['leer'] ?? false,
      actualizar: json['actualizar'] ?? false,
      eliminar: json['eliminar'] ?? false,
      asignarConductor: json['asignarConductor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crear': crear,
      'leer': leer,
      'actualizar': actualizar,
      'eliminar': eliminar,
      'asignarConductor': asignarConductor,
    };
  }
}

class PermisosAbastecimientos {
  final bool crear;
  final bool leer;
  final bool actualizar;
  final bool eliminar;
  final bool aprobar;
  final bool rechazar;

  PermisosAbastecimientos({
    required this.crear,
    required this.leer,
    required this.actualizar,
    required this.eliminar,
    required this.aprobar,
    required this.rechazar,
  });

  factory PermisosAbastecimientos.fromJson(Map<String, dynamic> json) {
    return PermisosAbastecimientos(
      crear: json['crear'] ?? false,
      leer: json['leer'] ?? false,
      actualizar: json['actualizar'] ?? false,
      eliminar: json['eliminar'] ?? false,
      aprobar: json['aprobar'] ?? false,
      rechazar: json['rechazar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crear': crear,
      'leer': leer,
      'actualizar': actualizar,
      'eliminar': eliminar,
      'aprobar': aprobar,
      'rechazar': rechazar,
    };
  }
}

class PermisosMantenimientos {
  final bool crear;
  final bool leer;
  final bool actualizar;
  final bool programar;

  PermisosMantenimientos({
    required this.crear,
    required this.leer,
    required this.actualizar,
    required this.programar,
  });

  factory PermisosMantenimientos.fromJson(Map<String, dynamic> json) {
    return PermisosMantenimientos(
      crear: json['crear'] ?? false,
      leer: json['leer'] ?? false,
      actualizar: json['actualizar'] ?? false,
      programar: json['programar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crear': crear,
      'leer': leer,
      'actualizar': actualizar,
      'programar': programar,
    };
  }
}

class PermisosFallas {
  final bool crear;
  final bool leer;
  final bool actualizar;
  final bool programar;

  PermisosFallas({
    required this.crear,
    required this.leer,
    required this.actualizar,
    required this.programar,
  });

  factory PermisosFallas.fromJson(Map<String, dynamic> json) {
    return PermisosFallas(
      crear: json['crear'] ?? false,
      leer: json['leer'] ?? false,
      actualizar: json['actualizar'] ?? false,
      programar: json['programar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'crear': crear,
      'leer': leer,
      'actualizar': actualizar,
      'programar': programar,
    };
  }
}

class PermisosReportes {
  final bool ver;
  final bool exportar;
  final bool configurar;

  PermisosReportes({
    required this.ver,
    required this.exportar,
    required this.configurar,
  });

  factory PermisosReportes.fromJson(Map<String, dynamic> json) {
    return PermisosReportes(
      ver: json['ver'] ?? false,
      exportar: json['exportar'] ?? false,
      configurar: json['configurar'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ver': ver,
      'exportar': exportar,
      'configurar': configurar,
    };
  }
}

class PermisosAdministrativo {
  final bool configurarSistema;
  final bool gestionarRoles;
  final bool verAuditoria;

  PermisosAdministrativo({
    required this.configurarSistema,
    required this.gestionarRoles,
    required this.verAuditoria,
  });

  factory PermisosAdministrativo.fromJson(Map<String, dynamic> json) {
    return PermisosAdministrativo(
      configurarSistema: json['configurarSistema'] ?? false,
      gestionarRoles: json['gestionarRoles'] ?? false,
      verAuditoria: json['verAuditoria'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'configurarSistema': configurarSistema,
      'gestionarRoles': gestionarRoles,
      'verAuditoria': verAuditoria,
    };
  }
}
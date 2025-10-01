class Role {
    Rol rol;

    Role({
        required this.rol,
    });

    factory Role.fromJson(Map<String, dynamic> json) => Role(
        rol: Rol.fromJson(json["rol"]),
    );

    Map<String, dynamic> toJson() => {
        "rol": rol.toJson(),
    };
}

class Rol {
    int id;
    String nombre;
    String descripcion;
    Permisos permisos;

    Rol({
        required this.id,
        required this.nombre,
        required this.descripcion,
        required this.permisos,
    });

    factory Rol.fromJson(Map<String, dynamic> json) => Rol(
        id: json["id"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        permisos: Permisos.fromJson(json["permisos"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "permisos": permisos.toJson(),
    };
}

class Permisos {
    Reportes reportes;
    Unidades unidades;
    Unidades usuarios;
    Administrativo administrativo;
    Mantenimientos mantenimientos;
    Abastecimientos abastecimientos;

    Permisos({
        required this.reportes,
        required this.unidades,
        required this.usuarios,
        required this.administrativo,
        required this.mantenimientos,
        required this.abastecimientos,
    });

    factory Permisos.fromJson(Map<String, dynamic> json) => Permisos(
        reportes: Reportes.fromJson(json["reportes"]),
        unidades: Unidades.fromJson(json["unidades"]),
        usuarios: Unidades.fromJson(json["usuarios"]),
        administrativo: Administrativo.fromJson(json["administrativo"]),
        mantenimientos: Mantenimientos.fromJson(json["mantenimientos"]),
        abastecimientos: Abastecimientos.fromJson(json["abastecimientos"]),
    );

    Map<String, dynamic> toJson() => {
        "reportes": reportes.toJson(),
        "unidades": unidades.toJson(),
        "usuarios": usuarios.toJson(),
        "administrativo": administrativo.toJson(),
        "mantenimientos": mantenimientos.toJson(),
        "abastecimientos": abastecimientos.toJson(),
    };
}

class Abastecimientos {
    bool leer;
    bool crear;
    bool aprobar;
    bool eliminar;
    bool rechazar;
    bool actualizar;

    Abastecimientos({
        required this.leer,
        required this.crear,
        required this.aprobar,
        required this.eliminar,
        required this.rechazar,
        required this.actualizar,
    });

    factory Abastecimientos.fromJson(Map<String, dynamic> json) => Abastecimientos(
        leer: json["leer"],
        crear: json["crear"],
        aprobar: json["aprobar"],
        eliminar: json["eliminar"],
        rechazar: json["rechazar"],
        actualizar: json["actualizar"],
    );

    Map<String, dynamic> toJson() => {
        "leer": leer,
        "crear": crear,
        "aprobar": aprobar,
        "eliminar": eliminar,
        "rechazar": rechazar,
        "actualizar": actualizar,
    };
}

class Administrativo {
    bool verAuditoria;
    bool gestionarRoles;
    bool configurarSistema;

    Administrativo({
        required this.verAuditoria,
        required this.gestionarRoles,
        required this.configurarSistema,
    });

    factory Administrativo.fromJson(Map<String, dynamic> json) => Administrativo(
        verAuditoria: json["verAuditoria"],
        gestionarRoles: json["gestionarRoles"],
        configurarSistema: json["configurarSistema"],
    );

    Map<String, dynamic> toJson() => {
        "verAuditoria": verAuditoria,
        "gestionarRoles": gestionarRoles,
        "configurarSistema": configurarSistema,
    };
}

class Mantenimientos {
    bool leer;
    bool crear;
    bool programar;
    bool actualizar;

    Mantenimientos({
        required this.leer,
        required this.crear,
        required this.programar,
        required this.actualizar,
    });

    factory Mantenimientos.fromJson(Map<String, dynamic> json) => Mantenimientos(
        leer: json["leer"],
        crear: json["crear"],
        programar: json["programar"],
        actualizar: json["actualizar"],
    );

    Map<String, dynamic> toJson() => {
        "leer": leer,
        "crear": crear,
        "programar": programar,
        "actualizar": actualizar,
    };
}

class Reportes {
    bool ver;
    bool exportar;
    bool configurar;

    Reportes({
        required this.ver,
        required this.exportar,
        required this.configurar,
    });

    factory Reportes.fromJson(Map<String, dynamic> json) => Reportes(
        ver: json["ver"],
        exportar: json["exportar"],
        configurar: json["configurar"],
    );

    Map<String, dynamic> toJson() => {
        "ver": ver,
        "exportar": exportar,
        "configurar": configurar,
    };
}

class Unidades {
    bool leer;
    bool crear;
    bool eliminar;
    bool actualizar;
    bool? asignarConductor;

    Unidades({
        required this.leer,
        required this.crear,
        required this.eliminar,
        required this.actualizar,
        this.asignarConductor,
    });

    factory Unidades.fromJson(Map<String, dynamic> json) => Unidades(
        leer: json["leer"],
        crear: json["crear"],
        eliminar: json["eliminar"],
        actualizar: json["actualizar"],
        asignarConductor: json["asignarConductor"],
    );

    Map<String, dynamic> toJson() => {
        "leer": leer,
        "crear": crear,
        "eliminar": eliminar,
        "actualizar": actualizar,
        "asignarConductor": asignarConductor,
    };
}

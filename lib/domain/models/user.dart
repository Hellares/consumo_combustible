import 'package:consumo_combustible/domain/models/roles.dart';

class User {
    int id;
    String nombres;
    String apellidos;
    String email;
    String telefono;
    String dni;
    String codigoEmpleado;
    DateTime fechaIngreso;
    bool activo;
    List<Role> roles;

    User({
        required this.id,
        required this.nombres,
        required this.apellidos,
        required this.email,
        required this.telefono,
        required this.dni,
        required this.codigoEmpleado,
        required this.fechaIngreso,
        required this.activo,
        required this.roles,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        nombres: json["nombres"],
        apellidos: json["apellidos"],
        email: json["email"],
        telefono: json["telefono"],
        dni: json["dni"],
        codigoEmpleado: json["codigoEmpleado"],
        fechaIngreso: DateTime.parse(json["fechaIngreso"]),
        activo: json["activo"],
        roles: List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "nombres": nombres,
        "apellidos": apellidos,
        "email": email,
        "telefono": telefono,
        "dni": dni,
        "codigoEmpleado": codigoEmpleado,
        "fechaIngreso": fechaIngreso.toIso8601String(),
        "activo": activo,
        "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
    };
}
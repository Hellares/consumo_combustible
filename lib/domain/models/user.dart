import 'package:consumo_combustible/domain/models/simple_role.dart';
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
    dynamic roles; // Can be List<Role> or List<SimpleRole> depending on endpoint

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

    factory User.fromJson(Map<String, dynamic> json) {
        // Check if roles have the 'rol' property (full Role) or just 'id' and 'nombre' (SimpleRole)
        List<dynamic> rolesData = json["roles"] ?? [];
        dynamic parsedRoles;
        
        if (rolesData.isNotEmpty) {
            if (rolesData.first is Map && rolesData.first.containsKey('rol')) {
                // Full Role structure from auth
                parsedRoles = List<Role>.from(rolesData.map((x) => Role.fromJson(x)));
            } else {
                // Simple role structure from user list
                parsedRoles = List<SimpleRole>.from(rolesData.map((x) => SimpleRole.fromJson(x)));
            }
        } else {
            parsedRoles = <SimpleRole>[];
        }

        return User(
            id: json["id"],
            nombres: json["nombres"],
            apellidos: json["apellidos"],
            email: json["email"],
            telefono: json["telefono"],
            dni: json["dni"],
            codigoEmpleado: json["codigoEmpleado"],
            fechaIngreso: DateTime.parse(json["fechaIngreso"]),
            activo: json["activo"],
            roles: parsedRoles,
        );
    }

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
        "roles": roles is List<Role>
            ? List<dynamic>.from((roles as List<Role>).map((x) => x.toJson()))
            : List<dynamic>.from((roles as List<SimpleRole>).map((x) => x.toJson())),
    };
    
    // Helper methods to safely access roles
    List<Role> get fullRoles => roles is List<Role> ? roles as List<Role> : [];
    List<SimpleRole> get simpleRoles => roles is List<SimpleRole> ? roles as List<SimpleRole> : [];
    
    bool get hasRoles => (roles is List && (roles as List).isNotEmpty);
}
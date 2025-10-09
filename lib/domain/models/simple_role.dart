class SimpleRole {
  final int id;
  final String nombre;

  SimpleRole({
    required this.id,
    required this.nombre,
  });

  factory SimpleRole.fromJson(Map<String, dynamic> json) => SimpleRole(
    id: json["id"],
    nombre: json["nombre"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
  };
}
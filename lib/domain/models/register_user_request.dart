// lib/domain/models/register_user_request.dart

class RegisterUserRequest {
  final String nombres;
  final String apellidos;
  final String email;
  final String telefono;
  final String dni;
  final String fechaIngreso;

  RegisterUserRequest({
    required this.nombres,
    required this.apellidos,
    required this.email,
    required this.telefono,
    required this.dni,
    required this.fechaIngreso,
  });

  Map<String, dynamic> toJson() => {
        'nombres': nombres,
        'apellidos': apellidos,
        'email': email,
        'telefono': telefono,
        'dni': dni,
        'fechaIngreso': fechaIngreso,
      };

  factory RegisterUserRequest.fromJson(Map<String, dynamic> json) =>
      RegisterUserRequest(
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        email: json['email'] as String,
        telefono: json['telefono'] as String,
        dni: json['dni'] as String,
        fechaIngreso: json['fechaIngreso'] as String,
      );
}
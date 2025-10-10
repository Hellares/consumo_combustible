// ✅ lib/domain/models/user_selection.dart
// Modelo simple para usuario seleccionado - Adaptado a tu User model

import 'package:consumo_combustible/domain/models/user.dart';

class UserSelection {
  final int id;
  final String nombreCompleto;
  final String? dni; // Opcional, por si necesitas mostrarlo como referencia

  UserSelection({
    required this.id,
    required this.nombreCompleto,
    this.dni,
  });

  // Factory desde tu modelo User
  factory UserSelection.fromUser(User user) {
    return UserSelection(
      id: user.id,
      nombreCompleto: '${user.nombres} ${user.apellidos}'.trim(),
      dni: user.dni,
    );
  }

  // Factory desde JSON (si necesitas serialización)
  factory UserSelection.fromJson(Map<String, dynamic> json) {
    return UserSelection(
      id: json['id'] ?? 0,
      nombreCompleto: json['nombreCompleto'] ?? '',
      dni: json['dni'],
    );
  }

  // To JSON (si necesitas serialización)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'dni': dni,
    };
  }

  // Para debugging
  @override
  String toString() => 'UserSelection(id: $id, nombreCompleto: $nombreCompleto)';

  // Equality (útil para comparaciones)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSelection && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
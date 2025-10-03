// lib/domain/models/selected_role.dart
import 'package:consumo_combustible/domain/models/roles.dart';

class SelectedRole {
  final int userId;
  final Role role;
  final DateTime selectedAt;

  SelectedRole({
    required this.userId,
    required this.role,
    required this.selectedAt,
  });

  factory SelectedRole.fromJson(Map<String, dynamic> json) => SelectedRole(
    userId: json['userId'],
    role: Role.fromJson(json['role']),
    selectedAt: DateTime.parse(json['selectedAt']),
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'role': role.toJson(),
    'selectedAt': selectedAt.toIso8601String(),
  };
}
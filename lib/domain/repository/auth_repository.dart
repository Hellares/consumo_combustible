

import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class AuthRepository {

  Future<AuthResponse?> getUserSession();
  Future<bool> logout();
  Future<void> saveUserSession(AuthResponse authResponse);
  Future<Resource<AuthResponse>> login(String dni, String password);

  // 🆕 Métodos para refresh tokens
  Future<Resource<AuthResponse>> refreshToken(String refreshToken);
  Future<bool> logoutAll();
  Future<String?> getRefreshToken();

  // 🆕 Métodos para rol
  Future<void> saveSelectedRole(SelectedRole selectedRole);
  Future<SelectedRole?> getSelectedRole();
  Future<void> clearSelectedRole();

}
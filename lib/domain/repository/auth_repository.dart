

import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class AuthRepository {

  Future<AuthResponse?> getUserSession(); 
  Future<bool> logout(); 
  Future<void> saveUserSession(AuthResponse authResponse);
  Future<Resource<AuthResponse>> login(String dni, String password);
  // Future<Resource<AuthResponseRegisterNew>> register(UserRegisterNew user);

}
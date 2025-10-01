

import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';

class SaveUserSessionUseCase{
  AuthRepository authRepository;

  SaveUserSessionUseCase(this.authRepository);

  Future<void> run(AuthResponse authResponse) => authRepository.saveUserSession(authResponse);
}


import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';

class GetUserSessionUseCase{
  AuthRepository authRepository;

  GetUserSessionUseCase(this.authRepository);

  Future<AuthResponse?> run() => authRepository.getUserSession();
}
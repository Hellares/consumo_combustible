import 'package:consumo_combustible/domain/repository/auth_repository.dart';


class LogoutAllUseCase {
  final AuthRepository authRepository;
  
  LogoutAllUseCase(this.authRepository);
  
  Future<bool> run() => authRepository.logoutAll();
}
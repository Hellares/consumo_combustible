import 'package:consumo_combustible/domain/repository/auth_repository.dart';


class GetRefreshTokenUseCase {
  final AuthRepository authRepository;
  
  GetRefreshTokenUseCase(this.authRepository);
  
  Future<String?> run() => authRepository.getRefreshToken();
}
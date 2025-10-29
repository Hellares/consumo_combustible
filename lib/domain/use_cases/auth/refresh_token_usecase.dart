import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';


class RefreshTokenUseCase {
  final AuthRepository authRepository;
  
  RefreshTokenUseCase(this.authRepository);
  
  Future<Resource<AuthResponse>> run(String refreshToken) => 
      authRepository.refreshToken(refreshToken);
}
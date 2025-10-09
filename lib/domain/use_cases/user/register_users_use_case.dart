import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class RegisterUserUseCase {
  final UserRepository repository;

  RegisterUserUseCase(this.repository);

  Future<Resource<AuthResponse>> run(RegisterUserRequest request) {
    return repository.registerUser(request);
  }
}




import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class LoginUseCase {

  AuthRepository repository;
  LoginUseCase(this.repository);


  // run(String dni, String password) => repository.login(dni, password);
  //o
  Future<Resource<AuthResponse>> run(String dni, String password) => repository.login(dni, password);

}
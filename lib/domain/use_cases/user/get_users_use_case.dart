
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetUsersUseCase {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  Future<Resource<UserResponse>> run({int page = 1, int pageSize = 10}) => _repository.getUsers(page: page, pageSize: pageSize);
}

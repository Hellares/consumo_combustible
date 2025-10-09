
import 'package:consumo_combustible/domain/repository/user_repository.dart';

class GetUsersUseCase {
  final UserRepository _repository;

  GetUsersUseCase(this._repository);

  run({int page = 1, int pageSize = 10}) => _repository.getUsers(page: page, pageSize: pageSize);
}

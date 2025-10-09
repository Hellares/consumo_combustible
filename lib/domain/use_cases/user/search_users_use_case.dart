
import 'package:consumo_combustible/domain/repository/user_repository.dart';

class SearchUsersUseCase {
  final UserRepository _repository;

  SearchUsersUseCase(this._repository);

  run(String query, {String searchType = 'nombre'}) =>
      _repository.searchUsers(query, searchType: searchType);
}

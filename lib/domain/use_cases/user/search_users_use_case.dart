
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class SearchUsersUseCase {
  final UserRepository _repository;

  SearchUsersUseCase(this._repository);

  Future<Resource<UserResponse>> run(String query, {String searchType = 'nombre'}) =>
      _repository.searchUsers(query, searchType: searchType);
}

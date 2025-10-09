
import 'package:consumo_combustible/data/datasource/remote/service/user_service.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserService _userService;

  UserRepositoryImpl(this._userService);

  @override
  Future<Resource<UserResponse>> getUsers({int page = 1, int pageSize = 10}) {
    return _userService.getUsers(page: page, pageSize: pageSize);
  }

  @override
  Future<Resource<UserResponse>> searchUsers(String query, {String searchType = 'nombre'}) {
    return _userService.searchUsers(query, searchType: searchType);
  }

  @override
  Future<Resource<AuthResponse>> registerUser(RegisterUserRequest request) {
    return _userService.registerUser(request);
  }
}

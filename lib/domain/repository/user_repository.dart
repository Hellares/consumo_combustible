
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class UserRepository {
  Future<Resource<UserResponse>> getUsers({int page, int pageSize});
  Future<Resource<UserResponse>> searchUsers(String query, {String searchType});
  Future<Resource<AuthResponse>> registerUser(RegisterUserRequest request);
}


import 'package:consumo_combustible/domain/use_cases/user/assign_rol_to_user_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/get_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/register_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/search_users_use_case.dart';

class UserUseCases {
  final GetUsersUseCase getUsers;
  final SearchUsersUseCase searchUsers;
  final RegisterUserUseCase registerUser;
  final AssignRolToUserUseCase assignRolToUser;

  UserUseCases({
    required this.getUsers,
    required this.searchUsers,
    required this.registerUser,
    required this.assignRolToUser,
  });
}

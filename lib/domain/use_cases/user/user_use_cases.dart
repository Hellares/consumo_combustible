
import 'package:consumo_combustible/domain/use_cases/user/get_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/search_users_use_case.dart';

class UserUseCases {
  final GetUsersUseCase getUsers;
  final SearchUsersUseCase searchUsers;

  UserUseCases({
    required this.getUsers,
    required this.searchUsers,
  });
}

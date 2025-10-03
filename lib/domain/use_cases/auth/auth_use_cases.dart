

import 'package:consumo_combustible/domain/use_cases/auth/get_selected_role_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_user_session_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/login_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_selected_role_usecase.dart';
// import 'package:consumo_combustible/domain/use_cases/auth/logout_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_user_session_usecase.dart';

class AuthUseCases {
  
  LoginUseCase login;
  // RegisterUseCase register;
  SaveUserSessionUseCase saveUserSession;
  GetUserSessionUseCase getUserSession;
  // LogoutUseCase logout;

  SaveSelectedRoleUseCase saveSelectedRole;
  GetSelectedRoleUseCase getSelectedRole;

  AuthUseCases({
    required this.login,
    // required this.register,
    required this.saveUserSession,
    required this.getUserSession,
    required this.saveSelectedRole,
    required this.getSelectedRole,
    // required this.logout
  });
}


import 'package:consumo_combustible/domain/use_cases/auth/get_refresh_token_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_selected_role_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_user_session_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/login_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/auth/logout_all_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/logout_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/refresh_token_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_selected_role_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_user_session_usecase.dart';

class AuthUseCases {
  
  LoginUseCase login;
  SaveUserSessionUseCase saveUserSession;
  GetUserSessionUseCase getUserSession;
  LogoutUseCase logout;
  LogoutAllUseCase logoutAll;
  RefreshTokenUseCase refreshToken;
  GetRefreshTokenUseCase getRefreshToken;

  SaveSelectedRoleUseCase saveSelectedRole;
  GetSelectedRoleUseCase getSelectedRole;

  AuthUseCases({
    required this.login,
    required this.saveUserSession,
    required this.getUserSession,
    required this.logout,
    required this.logoutAll,
    required this.refreshToken,
    required this.getRefreshToken,
    required this.saveSelectedRole,
    required this.getSelectedRole,
  });
}
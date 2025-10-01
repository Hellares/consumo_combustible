import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/presentation/utils/bloc_form_item.dart';
import 'package:equatable/equatable.dart';


abstract class LoginEvent extends Equatable{
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends LoginEvent {
  const InitEvent();
}

class LoginFormReset extends LoginEvent {
  const LoginFormReset();
}

class LoginSaveUserSession extends LoginEvent {
  final AuthResponse authResponse;
  const LoginSaveUserSession({ required this.authResponse});

  @override
  List<Object?> get props => [authResponse];
}

class DniChanged extends LoginEvent {
  final BlocFormItem dni;
  const DniChanged({ required this.dni });
  @override
  List<Object?> get props => [dni];
}

class PasswordChanged extends LoginEvent {
  final BlocFormItem password;
  const PasswordChanged({ required this.password });
  @override
  List<Object?> get props => [password];
}

class LoginSubmit extends LoginEvent {
  const LoginSubmit();
}

class ClearError extends LoginEvent {
  const ClearError();
}

class LogoutRequested extends LoginEvent {
  const LogoutRequested();
}


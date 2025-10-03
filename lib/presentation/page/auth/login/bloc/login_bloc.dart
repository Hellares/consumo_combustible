import 'dart:async';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:consumo_combustible/presentation/utils/bloc_form_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthUseCases authUseCases;

  // Cache de validación
  String? _lastDniValue;
  String? _lastPasswordValue;
  String? _lastDniError;
  String? _lastPasswordError;

  // Control de spam
  DateTime? _lastSubmitTime;
  static const Duration _submitDebounce = Duration(milliseconds: 800);

  // Control de cancelación
  Timer? _validationTimer;

  // Métricas de performance (solo en debug)
  final List<Duration> _loginTimes = [];

  LoginBloc(this.authUseCases) : super(const LoginState()) {
    on<InitEvent>(_onInitEvent);
    on<DniChanged>(_onDniChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmit>(_onLoginSubmit);
    on<LoginSaveUserSession>(_onLoginSaveUserSession);
    on<ClearError>(_onClearError);
    on<LoginFormReset>(_onFormReset);
    // on<LogoutRequested>(_onLogoutRequested);
  }

  final formKey = GlobalKey<FormState>();

  Future<void> _onInitEvent(InitEvent event, Emitter<LoginState> emit) async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
      print('🔄 Verificando sesión existente...');
    }

    try {
      final authResponse = await authUseCases.getUserSession.run();

      emit(state.copyWith(formKey: formKey));

      if (authResponse != null) {
        if (kDebugMode) {
          stopwatch?.stop();
          print(
            '✅ Sesión encontrada en ${stopwatch?.elapsedMilliseconds}ms para: ${authResponse.data?.user.nombres}',
          );
        }
        emit(state.copyWith(response: Success(authResponse), formKey: formKey));
      } else {
        if (kDebugMode) {
          stopwatch?.stop();
          print(
            'ℹ️ No hay sesión activa (verificado en ${stopwatch?.elapsedMilliseconds}ms)',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print(
          '❌ Error verificando sesión en ${stopwatch?.elapsedMilliseconds}ms: $e',
        );
      }
      emit(state.copyWith(formKey: formKey));
    }
  }

  

  Future<void> _onFormReset(
    LoginFormReset event,
    Emitter<LoginState> emit,
  ) async {
    if (kDebugMode) print('🔄 Reseteando formulario...');
    _clearValidationCache();
    _cancelPendingValidation();
    emit(const LoginState().copyWith(formKey: formKey));
  }

  Future<void> _onLoginSaveUserSession(
    LoginSaveUserSession event,
    Emitter<LoginState> emit,
  ) async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
    }

    try {
      if (kDebugMode) print('💾 Guardando sesión...');
      await authUseCases.saveUserSession.run(event.authResponse);

      if (kDebugMode) {
        stopwatch?.stop();
        print('✅ Sesión guardada en ${stopwatch?.elapsedMilliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) {
        stopwatch?.stop();
        print(
          '❌ Error guardando sesión en ${stopwatch?.elapsedMilliseconds}ms: $e',
        );
      }
      emit(
        state.copyWith(
          response: Error('Error al guardar sesión: ${e.toString()}'),
          formKey: formKey,
        ),
      );
    }
  }

  Future<void> _onDniChanged(DniChanged event, Emitter<LoginState> emit) async {
    // Cancelar validación pendiente
    _cancelPendingValidation();

    Resource? newResponse;
    if (state.response is Error) {
      newResponse = Initial();
    }

    // Validación inmediata para feedback rápido
    final dniError = _validateDniOptimized(event.dni.value);

    emit(
      state.copyWith(
        dni: BlocFormItem(value: event.dni.value, error: dniError),
        response: newResponse,
        formKey: formKey,
      ),
    );
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<LoginState> emit,
  ) async {
    _cancelPendingValidation();

    Resource? newResponse;
    if (state.response is Error) {
      newResponse = Initial();
    }

    final passwordError = _validatePasswordOptimized(event.password.value);

    emit(
      state.copyWith(
        password: BlocFormItem(
          value: event.password.value,
          error: passwordError,
        ),
        response: newResponse,
        formKey: formKey,
      ),
    );
  }

  Future<void> _onLoginSubmit(
    LoginSubmit event,
    Emitter<LoginState> emit,
  ) async {
    DateTime? submitStartTime;
    if (kDebugMode) {
      print('🔐 Submit iniciado...');
      submitStartTime = DateTime.now();
    }

    // Validación rápida sin async
    final dniError = _validateDniForSubmit(state.dni.value);
    final passwordError = _validatePasswordForSubmit(state.password.value);

    if (dniError != null || passwordError != null) {
      emit(
        state.copyWith(
          dni: state.dni.copyWith(error: dniError),
          password: state.password.copyWith(error: passwordError),
          formKey: formKey,
        ),
      );
      return;
    }

    // Loading inmediato
    emit(state.copyWith(response: Loading(), formKey: formKey));

    try {
      if (kDebugMode && submitStartTime != null) {
        final serviceStartTime = DateTime.now();
        final submitToServiceTime = serviceStartTime.difference(
          submitStartTime,
        );
        if (kDebugMode) {
          print('🏁 Tiempo hasta servicio: ${submitToServiceTime.inMilliseconds}ms',
        );
        }
      }

      Stopwatch? loginStopwatch;
      if (kDebugMode) {
        loginStopwatch = Stopwatch()..start();
      }

      final response = await authUseCases.login.run(
        state.dni.value,
        state.password.value,
      );

      if (kDebugMode) {
        loginStopwatch?.stop();
        final endTime = DateTime.now();
        final totalTime = submitStartTime != null
            ? endTime.difference(submitStartTime)
            : null;

        if (loginStopwatch != null) {
          _recordLoginTime(loginStopwatch.elapsed);
          print('⏱️ Login: ${loginStopwatch.elapsedMilliseconds}ms');
          print('📊 Promedio últimos 5 logins: ${_getAverageLoginTime()}ms');
        }

        if (totalTime != null) {
          print('⏱️ Total submit: ${totalTime.inMilliseconds}ms');
        }
      }

      emit(state.copyWith(response: response, formKey: formKey));
    } catch (e) {
      if (kDebugMode) {
        final endTime = DateTime.now();
        final totalTime = submitStartTime != null
            ? endTime.difference(submitStartTime)
            : null;
        print('💥 Error en ${totalTime?.inMilliseconds ?? 0}ms: $e');
      }

      emit(
        state.copyWith(
          response: Error('Error: ${e.toString()}'),
          formKey: formKey,
        ),
      );
    }
  }

  Future<void> _onClearError(ClearError event, Emitter<LoginState> emit) async {
    emit(state.copyWith(response: Initial(), formKey: formKey));
  }

  
  /*
    ***************************************************************************************
    Metodo: logoutRequested
    Fecha: 16-09-2025
    Descripcion: logout del usuario, limpia la sesion y resetea el estado del bloc y cache de validacion
    Autor: James Torres
    ***************************************************************************************
  */  

  // Future<void> _onLogoutRequested(LogoutRequested event,Emitter<LoginState> emit) async {
  //   Stopwatch? stopwatch;
  //   if (kDebugMode) {
  //     stopwatch = Stopwatch()..start();
  //     print('🚪 Iniciando logout...');
  //   }

  //   try {
  //     // Loading inmediato
  //     emit(state.copyWith(response: Loading(), formKey: formKey));

  //     // Ejecutar logout a través del use case
  //     final logoutSuccess = await authUseCases.logout.run();

  //     if (kDebugMode) {
  //       stopwatch?.stop();
  //       print('✅ Logout completado en ${stopwatch?.elapsedMilliseconds}ms - Success: $logoutSuccess');
  //     }

  //     if (logoutSuccess) {
  //       // Reset completo del estado tras logout exitoso
  //       _clearValidationCache();
  //       _cancelPendingValidation();
        
  //       // Estado limpio que indica logout exitoso
  //       emit(const LoginState().copyWith(
  //         response: Success('Sesión cerrada exitosamente'),
  //         formKey: formKey,
  //       ));
        
  //       if (kDebugMode) print('🔄 Estado reseteado después del logout');
  //     } else {
  //       // Error en logout
  //       emit(state.copyWith(
  //         response: Error('Error al cerrar sesión. Intenta nuevamente.'),
  //         formKey: formKey,
  //       ));
  //     }

  //   } catch (e) {
  //     if (kDebugMode) {
  //       stopwatch?.stop();
  //       print('💥 Error en logout (${stopwatch?.elapsedMilliseconds}ms): $e');
  //     }

  //     emit(state.copyWith(
  //       response: Error('Error al cerrar sesión: ${e.toString()}'),
  //       formKey: formKey,
  //     ));
  //   }
  // }

  // VALIDACIÓN OPTIMIZADA
  String? _validateDniOptimized(String dni) {
    if (_lastDniValue == dni) {
      return _lastDniError;
    }

    _lastDniValue = dni;

    if (dni.isEmpty) {
      _lastDniError = null;
      return null;
    }

    if (dni.length != 8 || !RegExp(r'^\d+$').hasMatch(dni)) {
      _lastDniError = 'DNI debe tener 8 dígitos';
    } else {
      _lastDniError = null;
    }

    return _lastDniError;
  }

  String? _validatePasswordOptimized(String password) {
    if (_lastPasswordValue == password) {
      return _lastPasswordError;
    }

    _lastPasswordValue = password;

    if (password.isEmpty) {
      _lastPasswordError = null;
      return null;
    }

    if (password.length < 6) {
      _lastPasswordError = 'Mínimo 6 caracteres';
    } else {
      _lastPasswordError = null;
    }

    return _lastPasswordError;
  }

  String? _validateDniForSubmit(String dni) {
    if (dni.isEmpty) return 'DNI requerido';
    if (dni.length != 8) return 'DNI debe tener 8 dígitos';
    if (!RegExp(r'^\d+$').hasMatch(dni)) {
      return 'DNI solo debe contener números';
    }
    return null;
  }

  String? _validatePasswordForSubmit(String password) {
    if (password.isEmpty) return 'Contraseña requerida';
    if (password.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  // MÉTRICAS Y PERFORMANCE (solo en debug)
  void _recordLoginTime(Duration duration) {
    if (kDebugMode) {
      _loginTimes.add(duration);
      if (_loginTimes.length > 10) {
        _loginTimes.removeAt(0); // Mantener solo últimos 10
      }
    }
  }

  int _getAverageLoginTime() {
    if (!kDebugMode || _loginTimes.isEmpty) return 0;
    final totalMs = _loginTimes
        .map((d) => d.inMilliseconds)
        .reduce((a, b) => a + b);
    return (totalMs / _loginTimes.length).round();
  }

  // HELPERS
  void _clearValidationCache() {
    _lastDniValue = null;
    _lastPasswordValue = null;
    _lastDniError = null;
    _lastPasswordError = null;
    _lastSubmitTime = null;
  }

  void _cancelPendingValidation() {
    _validationTimer?.cancel();
    _validationTimer = null;
  }

  // GETTERS
  bool get isFormValid {
    return state.dni.value.isNotEmpty &&
        state.password.value.isNotEmpty &&
        state.dni.error == null &&
        state.password.error == null;
  }

  bool get canSubmit {
    return isFormValid &&
        state.response is! Loading &&
        (_lastSubmitTime == null ||
            DateTime.now().difference(_lastSubmitTime!) >= _submitDebounce);
  }

  bool get canLogout {
    return state.response is! Loading;
  }

  @override
  Future<void> close() {
    _cancelPendingValidation();
    _clearValidationCache();
    return super.close();
  }
}

import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/api/dio_config.dart';
import 'package:consumo_combustible/data/datasource/remote/service/auth_service.dart';
import 'package:consumo_combustible/data/repository/auth_repository_impl.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_user_session_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/login_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/auth/logout_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_user_session_usecase.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';


@module
abstract class AppModule {
  
  // ✅ CORE DEPENDENCIES - Solo UNA instancia
  @singleton
  Dio dio() {
    if (kDebugMode) print('🔧 Creando Dio singleton');
    return DioConfig.instance;
  }
  
  // ✅ CAMBIO PRINCIPAL: FastStorageService en lugar de SecureStorage
  @singleton
  FastStorageService fastStorageService() {
    if (kDebugMode) print('⚡ Creando FastStorageService singleton');
    return FastStorageService();
  }
  
  // ✅ SERVICES - Factory en lugar de Singleton para mejor performance
  @injectable
  AuthService authService(Dio dio) {
    if (kDebugMode) print('🔐 Creando AuthService');
    return AuthService(); // Usa DioConfig.instance internamente
  }
  
  // ✅ REPOSITORIES - Singleton con FastStorageService
  @singleton
  AuthRepository authRepository(AuthService authService, FastStorageService fastStorage) {
    if (kDebugMode) print('📚 Creando AuthRepository singleton');
    return AuthRepositoryImpl(authService, fastStorage);
  }
  
  
  // ✅ USE CASES CONTAINERS - Singleton optimizado
  @singleton
  AuthUseCases authUseCases(AuthRepository authRepository) {
    if (kDebugMode) print('🎯 Creando AuthUseCases singleton');
    
    return AuthUseCases(
      login: LoginUseCase(authRepository),
      // register: RegisterUseCase(authRepository),
      saveUserSession: SaveUserSessionUseCase(authRepository),
      getUserSession: GetUserSessionUseCase(authRepository),
      logout: LogoutUseCase(authRepository),
    );
  }
  
}
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:consumo_combustible/core/fast_storage_service.dart' as _i782;
import 'package:consumo_combustible/data/datasource/remote/service/auth_service.dart'
    as _i14;
import 'package:consumo_combustible/data/datasource/remote/service/location_service.dart'
    as _i200;
import 'package:consumo_combustible/data/datasource/remote/service/ticket_service.dart'
    as _i1037;
import 'package:consumo_combustible/di/app_module.dart' as _i564;
import 'package:consumo_combustible/domain/repository/auth_repository.dart'
    as _i120;
import 'package:consumo_combustible/domain/repository/location_repository.dart'
    as _i611;
import 'package:consumo_combustible/domain/repository/ticket_repository.dart'
    as _i107;
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart'
    as _i960;
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart'
    as _i636;
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart'
    as _i453;
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.singleton<_i361.Dio>(() => appModule.dio());
    gh.singleton<_i782.FastStorageService>(
      () => appModule.fastStorageService(),
    );
    gh.factory<_i14.AuthService>(() => appModule.authService(gh<_i361.Dio>()));
    gh.factory<_i200.LocationService>(
      () => appModule.locationService(gh<_i361.Dio>()),
    );
    gh.factory<_i1037.TicketService>(
      () => appModule.ticketService(gh<_i361.Dio>()),
    );
    gh.singleton<_i611.LocationRepository>(
      () => appModule.locationRepository(
        gh<_i200.LocationService>(),
        gh<_i782.FastStorageService>(),
      ),
    );
    gh.singleton<_i636.LocationUseCases>(
      () => appModule.locationUseCases(gh<_i611.LocationRepository>()),
    );
    gh.singleton<_i107.TicketRepository>(
      () => appModule.ticketRepository(gh<_i1037.TicketService>()),
    );
    gh.singleton<_i120.AuthRepository>(
      () => appModule.authRepository(
        gh<_i14.AuthService>(),
        gh<_i782.FastStorageService>(),
      ),
    );
    gh.singleton<_i960.AuthUseCases>(
      () => appModule.authUseCases(gh<_i120.AuthRepository>()),
    );
    gh.singleton<_i453.TicketUseCases>(
      () => appModule.ticketUseCases(gh<_i107.TicketRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i564.AppModule {}

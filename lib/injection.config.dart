// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:consumo_combustible/core/fast_storage_service.dart' as _i782;
import 'package:consumo_combustible/data/datasource/remote/service/archivo_service.dart'
    as _i261;
import 'package:consumo_combustible/data/datasource/remote/service/auth_service.dart'
    as _i14;
import 'package:consumo_combustible/data/datasource/remote/service/detalle_abastecimiento_service.dart'
    as _i14;
import 'package:consumo_combustible/data/datasource/remote/service/licencia_service.dart'
    as _i858;
import 'package:consumo_combustible/data/datasource/remote/service/location_service.dart'
    as _i200;
import 'package:consumo_combustible/data/datasource/remote/service/ticket_aprobacion_service.dart'
    as _i425;
import 'package:consumo_combustible/data/datasource/remote/service/ticket_service.dart'
    as _i1037;
import 'package:consumo_combustible/data/datasource/remote/service/unidad_service.dart'
    as _i599;
import 'package:consumo_combustible/data/datasource/remote/service/user_service.dart'
    as _i148;
import 'package:consumo_combustible/di/app_module.dart' as _i564;
import 'package:consumo_combustible/domain/repository/archivo_repository.dart'
    as _i45;
import 'package:consumo_combustible/domain/repository/auth_repository.dart'
    as _i120;
import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart'
    as _i343;
import 'package:consumo_combustible/domain/repository/licencia_repository.dart'
    as _i1047;
import 'package:consumo_combustible/domain/repository/location_repository.dart'
    as _i611;
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart'
    as _i407;
import 'package:consumo_combustible/domain/repository/ticket_repository.dart'
    as _i107;
import 'package:consumo_combustible/domain/repository/unidad_repository.dart'
    as _i41;
import 'package:consumo_combustible/domain/repository/user_repository.dart'
    as _i607;
import 'package:consumo_combustible/domain/use_cases/archivo/archivo_use_cases.dart'
    as _i441;
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart'
    as _i960;
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/detalle_abastecimiento_use_cases.dart'
    as _i58;
import 'package:consumo_combustible/domain/use_cases/licencia/licencia_use_cases.dart'
    as _i767;
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart'
    as _i636;
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart'
    as _i453;
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/ticket_aprobacion_use_cases.dart'
    as _i148;
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart'
    as _i911;
import 'package:consumo_combustible/domain/use_cases/user/user_use_cases.dart'
    as _i974;
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
    gh.factory<_i599.UnidadService>(
      () => appModule.unidadService(gh<_i361.Dio>()),
    );
    gh.factory<_i425.TicketAprobacionService>(
      () => appModule.ticketAprobacionService(gh<_i361.Dio>()),
    );
    gh.factory<_i14.DetalleAbastecimientoService>(
      () => appModule.detalleAbastecimientoService(gh<_i361.Dio>()),
    );
    gh.factory<_i858.LicenciaService>(
      () => appModule.licenciaService(gh<_i361.Dio>()),
    );
    gh.factory<_i148.UserService>(() => appModule.userService(gh<_i361.Dio>()));
    gh.factory<_i261.ArchivoService>(
      () => appModule.archivoService(gh<_i361.Dio>()),
    );
    gh.singleton<_i343.DetalleAbastecimientoRepository>(
      () => appModule.detalleAbastecimientoRepository(
        gh<_i14.DetalleAbastecimientoService>(),
      ),
    );
    gh.singleton<_i407.TicketAprobacionRepository>(
      () => appModule.ticketAprobacionRepository(
        gh<_i425.TicketAprobacionService>(),
      ),
    );
    gh.singleton<_i611.LocationRepository>(
      () => appModule.locationRepository(
        gh<_i200.LocationService>(),
        gh<_i782.FastStorageService>(),
      ),
    );
    gh.singleton<_i607.UserRepository>(
      () => appModule.userRepository(gh<_i148.UserService>()),
    );
    gh.singleton<_i45.ArchivoRepository>(
      () => appModule.archivoRepository(gh<_i261.ArchivoService>()),
    );
    gh.singleton<_i58.DetalleAbastecimientoUseCases>(
      () => appModule.detalleAbastecimientoUseCases(
        gh<_i343.DetalleAbastecimientoRepository>(),
      ),
    );
    gh.singleton<_i974.UserUseCases>(
      () => appModule.userUseCases(gh<_i607.UserRepository>()),
    );
    gh.singleton<_i148.TicketAprobacionUseCases>(
      () => appModule.ticketAprobacionUseCases(
        gh<_i407.TicketAprobacionRepository>(),
      ),
    );
    gh.singleton<_i41.UnidadRepository>(
      () => appModule.unidadRepository(
        gh<_i599.UnidadService>(),
        gh<_i782.FastStorageService>(),
      ),
    );
    gh.singleton<_i911.UnidadUseCases>(
      () => appModule.unidadUseCases(gh<_i41.UnidadRepository>()),
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
    gh.singleton<_i1047.LicenciaRepository>(
      () => appModule.licenciaRepository(gh<_i858.LicenciaService>()),
    );
    gh.singleton<_i441.ArchivoUseCases>(
      () => appModule.archivoUseCases(gh<_i45.ArchivoRepository>()),
    );
    gh.singleton<_i960.AuthUseCases>(
      () => appModule.authUseCases(gh<_i120.AuthRepository>()),
    );
    gh.singleton<_i767.LicenciaUseCases>(
      () => appModule.licenciaUseCases(gh<_i1047.LicenciaRepository>()),
    );
    gh.singleton<_i453.TicketUseCases>(
      () => appModule.ticketUseCases(gh<_i107.TicketRepository>()),
    );
    return this;
  }
}

class _$AppModule extends _i564.AppModule {}

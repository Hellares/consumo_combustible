import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/data/api/dio_config.dart';
import 'package:consumo_combustible/data/datasource/remote/service/archivo_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/auth_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/grifo_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/licencia_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/location_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/detalle_abastecimiento_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/rol_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/sede_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/ticket_aprobacion_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/ticket_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/unidad_service.dart';
import 'package:consumo_combustible/data/datasource/remote/service/zona_service.dart';
import 'package:consumo_combustible/data/repository/archivo_repository_impl.dart';
import 'package:consumo_combustible/data/repository/auth_repository_impl.dart';
import 'package:consumo_combustible/data/repository/detalle_abastecimiento_repository_impl.dart';
import 'package:consumo_combustible/data/repository/grifo_repository_impl.dart';
import 'package:consumo_combustible/data/repository/licencia_repository_impl.dart';
import 'package:consumo_combustible/data/repository/location_repository_impl.dart';
import 'package:consumo_combustible/data/repository/rol_repository_impl.dart';
import 'package:consumo_combustible/data/repository/sede_repository_impl.dart';
import 'package:consumo_combustible/data/repository/ticket_aprobacion_repository_impl.dart';
import 'package:consumo_combustible/data/repository/ticket_repository_impl.dart';
import 'package:consumo_combustible/data/repository/unidad_repository_impl.dart';
import 'package:consumo_combustible/data/repository/zona_repository_impl.dart';
import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';
import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart';
import 'package:consumo_combustible/domain/repository/grifo_repository.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';
import 'package:consumo_combustible/domain/repository/rol_repository.dart';
import 'package:consumo_combustible/domain/repository/sede_repository.dart';
import 'package:consumo_combustible/domain/repository/ticket_aprobacion_repository.dart';
import 'package:consumo_combustible/domain/repository/ticket_repository.dart';
import 'package:consumo_combustible/domain/repository/unidad_repository.dart';
import 'package:consumo_combustible/domain/repository/zona_repository.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/archivo_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/delete_archivo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/get_archivos_byticket_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/get_tipos_archivos_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/upload_archivos_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_selected_role_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/get_user_session_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/login_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/auth/logout_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_selected_role_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/auth/save_user_session_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/create_grifo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifo_by_id_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifos_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/get_grifosgrifos_by_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/grifo_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/update_grifo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/create_licencia_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencia_by_id_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_by_usuario_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_proximas_vencer_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/get_licencias_vencidas_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/licencia_use_cases.dart';
import 'package:consumo_combustible/data/datasource/remote/service/user_service.dart';
import 'package:consumo_combustible/data/repository/user_repository_impl.dart';
import 'package:consumo_combustible/domain/repository/user_repository.dart';
import 'package:consumo_combustible/domain/use_cases/rol/activar_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/create_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/delete_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/get_rol_by_id_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/get_roles_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/rol/rol_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/rol/update_rol_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/create_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/get_sedes_sedes_by_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/get_sedes_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/sede_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/create_unidad_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/assign_rol_to_user_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/get_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/register_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/search_users_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/user/user_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/clear_selected_location_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_grifosby_sede_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_sedesby_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_selected_location_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/get_zonas_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/save_selected_location_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/actualizar_detalle.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/concluir_detalle.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/detalle_abastecimiento_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/get_detalles_abastecimiento.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/create_ticket_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/aprobar_ticket.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/aprobar_tickets_lote.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/get_tickets_solicitados.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/rechazar_ticket.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/ticket_aprobacion_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/clear_unidades_cache.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_all_unidades.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_unidad_by_id.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/get_unidades_by_zona.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/zona/create_zona_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/zona/get_zonas_zonas_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/zona/zona_use_cases.dart';
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

  @injectable
  LocationService locationService(Dio dio) => LocationService(dio);

  @singleton
  LocationRepository locationRepository(
    LocationService service,
    FastStorageService storage,
  ) => LocationRepositoryImpl(service, storage);
  
  @injectable
  TicketService ticketService(Dio dio) => TicketService(dio);

  @singleton
  TicketRepository ticketRepository(TicketService service) => 
    TicketRepositoryImpl(service);

  // NUEVO: UNIDAD SERVICE
  @injectable
  UnidadService unidadService(Dio dio) {
    if (kDebugMode) print('🚗 Creando UnidadService');
    return UnidadService(dio);
  }

  // NUEVO: UNIDAD REPOSITORY
  @singleton
  UnidadRepository unidadRepository(UnidadService service, FastStorageService storage,) {
    if (kDebugMode) print('📦 Creando UnidadRepository con caché');
    return UnidadRepositoryImpl(service, storage);
  }

  //TICKET APROBACION SERVICE
  @injectable
  TicketAprobacionService ticketAprobacionService(Dio dio) {
    if (kDebugMode) print('📋 Creando TicketAprobacionService');
    return TicketAprobacionService(dio);
  }
  
  //TICKET APROBACION REPOSITORY
  @singleton
  TicketAprobacionRepository ticketAprobacionRepository(
    TicketAprobacionService service,
  ) {
    if (kDebugMode) print('📦 Creando TicketAprobacionRepository singleton');
    return TicketAprobacionRepositoryImpl(service);
  }

  // DETALLE ABASTECIMIENTO SERVICE
  @injectable
  DetalleAbastecimientoService detalleAbastecimientoService(Dio dio) {
    if (kDebugMode) print('📊 Creando DetalleAbastecimientoService');
    return DetalleAbastecimientoService(dio);
  }

  // DETALLE ABASTECIMIENTO REPOSITORY
  @singleton
  DetalleAbastecimientoRepository detalleAbastecimientoRepository(
    DetalleAbastecimientoService service,
  ) {
    if (kDebugMode) print('📦 Creando DetalleAbastecimientoRepository singleton');
    return DetalleAbastecimientoRepositoryImpl(service);
  }

  @injectable
  LicenciaService licenciaService(Dio dio) {
    if (kDebugMode) print('📊 Creando licenciaService');
    return LicenciaService(dio);
  }

  @singleton
  LicenciaRepository licenciaRepository(LicenciaService service) =>
      LicenciaRepositoryImpl(service);

  @injectable
  UserService userService(Dio dio) {
    if (kDebugMode) print('📊 Creando userService');
    return UserService(dio);
  }

  @singleton
  UserRepository userRepository(UserService service) =>
      UserRepositoryImpl(service);

  // NUEVO: ARCHIVO SERVICE
  @injectable
  ArchivoService archivoService(Dio dio, FastStorageService storage) {
    if (kDebugMode) print('📎 Creando ArchivoService con caché');
    return ArchivoService(dio, storage);
  }

  // NUEVO: ARCHIVO REPOSITORY
  @singleton
  ArchivoRepository archivoRepository(ArchivoService service) {
    if (kDebugMode) print('📦 Creando ArchivoRepository singleton');
    return ArchivoRepositoryImpl(service);
  }

   @injectable
  ZonaService zonaService(Dio dio) {
    if (kDebugMode) print('🗺️ Creando ZonaService');
    return ZonaService(dio);
  }

  @singleton
  ZonaRepository zonaRepository(ZonaService service) {
    if (kDebugMode) print('📚 Creando ZonaRepository singleton');
    return ZonaRepositoryImpl(service);
  }

  @injectable
  SedeService sedeService(Dio dio) {
    if (kDebugMode) print('🏢 Creando SedeService');
    return SedeService(dio);
  }

  @singleton
  SedeRepository sedeRepository(SedeService service) {
    if (kDebugMode) print('📚 Creando SedeRepository singleton');
    return SedeRepositoryImpl(service);
  }

  @injectable
  GrifoService grifoService(Dio dio) {
    if (kDebugMode) print('⛽ Creando GrifoService');
    return GrifoService(dio);
  }

  @singleton
  GrifoRepository grifoRepository(GrifoService service) {
    if (kDebugMode) print('📚 Creando GrifoRepository singleton');
    return GrifoRepositoryImpl(service);
  }

   @factory
  RolService rolService(Dio dio, FastStorageService storage) {
    if (kDebugMode) print('🔧 Creando RolService');
    return RolService(dio, storage);
  }

  /// RolRepository - Implementación del repositorio
  @singleton
  RolRepository rolRepository(RolService service) {
    if (kDebugMode) print('🔧 Creando RolRepository singleton');
    return RolRepositoryImpl(service);
  }

  
  //---------------------------------------------------------------------------------//
  // ✅ USE CASES CONTAINERS - Singleton optimizado
  @singleton
  AuthUseCases authUseCases(AuthRepository authRepository) {
    if (kDebugMode) print('🎯 Creando AuthUseCases singleton');
    
    return AuthUseCases(
      login: LoginUseCase(authRepository),
      // register: RegisterUseCase(authRepository),
      saveUserSession: SaveUserSessionUseCase(authRepository),
      getUserSession: GetUserSessionUseCase(authRepository),
      saveSelectedRole: SaveSelectedRoleUseCase(authRepository),
      getSelectedRole: GetSelectedRoleUseCase(authRepository),
      logout: LogoutUseCase(authRepository),
    );
  }

  @singleton
  LocationUseCases locationUseCases(LocationRepository repository) {
    return LocationUseCases(
      getZonas: GetZonasUseCase(repository),
      getSedesByZona: GetSedesByZonaUseCase(repository),
      getGrifosBySede: GetGrifosBySedeUseCase(repository),
      saveSelectedLocation: SaveSelectedLocationUseCase(repository),
      getSelectedLocation: GetSelectedLocationUseCase(repository),
      clearSelectedLocation: ClearSelectedLocationUseCase(repository),
    );
  }
  
  @singleton
  TicketUseCases ticketUseCases(TicketRepository repository) {
    return TicketUseCases(
      createTicket: CreateTicketUseCase(repository),
    );
  }

  // NUEVO: UNIDAD USE CASES
  @singleton
  UnidadUseCases unidadUseCases(UnidadRepository repository) {
    if (kDebugMode) print('🎯 Creando UnidadUseCases singleton');
    
    return UnidadUseCases(
      getUnidadesByZona: GetUnidadesByZona(repository),
      getAllUnidades: GetAllUnidades(repository),
      getUnidadById: GetUnidadById(repository),
      clearUnidadesCache: ClearUnidadesCache(repository),
      createUnidad: CreateUnidadUseCase(repository),
    );
  }

  @singleton
  TicketAprobacionUseCases ticketAprobacionUseCases(
    TicketAprobacionRepository repository,
  ) {
    if (kDebugMode) print('🎯 Creando TicketAprobacionUseCases singleton');

    return TicketAprobacionUseCases(
      getTicketsSolicitados: GetTicketsSolicitados(repository),
      aprobarTicket: AprobarTicket(repository),
      rechazarTicket: RechazarTicket(repository),
      aprobarTicketsLote: AprobarTicketsLote(repository),
    );
  }

  @singleton
  DetalleAbastecimientoUseCases detalleAbastecimientoUseCases(
    DetalleAbastecimientoRepository repository,
  ) {
    if (kDebugMode) print('🎯 Creando DetalleAbastecimientoUseCases singleton');

    return DetalleAbastecimientoUseCases(
      getDetallesAbastecimiento: GetDetallesAbastecimiento(repository),
      actualizarDetalle: ActualizarDetalle(repository),
      concluirDetalle: ConcluirDetalle(repository),
    );
  }

  @singleton
  LicenciaUseCases licenciaUseCases(
    LicenciaRepository repository,
  ){
    if (kDebugMode) print('🎯 Creando LicenciaUseCases singleton');
    return LicenciaUseCases(
      getLicencias: GetLicenciasUseCase(repository),
      getLicenciaById: GetLicenciaByIdUseCase(repository),
      getLicenciasByUsuario: GetLicenciasByUsuarioUseCase(repository),
      getLicenciasVencidas: GetLicenciasVencidasUseCase(repository),
      getLicenciasProximasVencer: GetLicenciasProximasVencerUseCase(repository),
      createLicencia: CreateLicenciaUseCase(repository),
    );
  }

  @singleton
  UserUseCases userUseCases(
    UserRepository repository,
  ){
    if (kDebugMode) print('🎯 Creando UserUseCases singleton');
    return UserUseCases(
      getUsers: GetUsersUseCase(repository),
      searchUsers: SearchUsersUseCase(repository),
      registerUser: RegisterUserUseCase(repository),
      assignRolToUser: AssignRolToUserUseCase(repository),
    );
  }

  @singleton
  ArchivoUseCases archivoUseCases(ArchivoRepository repository) {
    if (kDebugMode) print('🎯 Creando ArchivoUseCases singleton');
    return ArchivoUseCases(
      getTiposArchivo: GetTiposArchivoUseCase(repository),
      uploadArchivos: UploadArchivosUseCase(repository),
      getArchivosByTicket: GetArchivosByTicketUseCase(repository),
      deleteArchivo: DeleteArchivoUseCase(repository),
    );
  }

  @singleton
  ZonaUseCases zonaUseCases(ZonaRepository repository) {
    if (kDebugMode) print('🎯 Creando ZonaUseCases singleton');
    return ZonaUseCases(
      createZona: CreateZonaUseCase(repository),
      getZonas: GetZonasZonasUseCase(repository),
    );
  }

  @singleton
  SedeUseCases sedeUseCases(SedeRepository repository) {
    if (kDebugMode) print('🎯 Creando SedeUseCases singleton');
    return SedeUseCases(
      createSede: CreateSedeUseCase(repository),
      getSedes: GetSedesUseCase(repository),
      getSedesSedesByZona: GetSedesSedesByZonaUseCase(repository),
    );
  }

  @singleton
  GrifoUseCases grifoUseCases(GrifoRepository repository) {
    if (kDebugMode) print('🎯 Creando GrifoUseCases singleton');
    return GrifoUseCases(
      createGrifo: CreateGrifoUseCase(repository),
      getGrifos: GetGrifosUseCase(repository),
      getGrifosBySede: GetGrifosGrifosBySedeUseCase(repository),
      getGrifoById: GetGrifoByIdUseCase(repository),
      updateGrifo: UpdateGrifoUseCase(repository),
    );
  }

  @singleton
  RolUseCases rolUseCases(RolRepository repository) {
    if (kDebugMode) print('🎯 Creando RolUseCases singleton');
    return RolUseCases(
      getRoles: GetRolesUseCase(repository),
      getRolById: GetRolByIdUseCase(repository),
      createRol: CreateRolUseCase(repository),
      updateRol: UpdateRolUseCase(repository),
      deleteRol: DeleteRolUseCase(repository),
      activarRol: ActivarRolUseCase(repository),
    );
  }
}
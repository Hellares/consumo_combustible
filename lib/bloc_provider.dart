import 'package:consumo_combustible/domain/use_cases/archivo/archivo_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/detalle_abastecimiento_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/gps/gps_usecases.dart';
import 'package:consumo_combustible/domain/use_cases/grifo/grifo_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/itinerario/itinerario_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/licencia/licencia_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/reporte/reporte_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/rol/rol_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ruta/ruta_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/sedes/sede_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/ticket_aprobacion_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/user/user_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/zona/zona_use_cases.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_bloc.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_bloc.dart';
import 'package:consumo_combustible/presentation/page/grifos/bloc/grifo_bloc.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_bloc.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_bloc.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_bloc.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_bloc.dart';
import 'package:consumo_combustible/presentation/page/sedes/bloc/sede_bloc.dart';
import 'package:consumo_combustible/presentation/page/unidad/bloc/unidad_bloc.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_bloc.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_bloc.dart';
import 'package:consumo_combustible/presentation/page/licencias/bloc/licencia_bloc.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_bloc.dart';
import 'package:consumo_combustible/presentation/page/zona/bloc/zona_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


List<BlocProvider> blocProviders = [

  BlocProvider<LoginBloc>(create: (context) => LoginBloc(locator<AuthUseCases>())),
  // InitEvent() solo se dispara cuando se muestra MainLoginPage
  BlocProvider<LocationBloc>(create: (context) => LocationBloc(locator<LocationUseCases>())),

  BlocProvider<TicketBloc>(create: (context) => TicketBloc(locator<TicketUseCases>(), locator<UnidadUseCases>())),

  BlocProvider<TicketAprobacionBloc>(create: (context) => TicketAprobacionBloc(locator<TicketAprobacionUseCases>())),

  BlocProvider<DetalleAbastecimientoBloc>(create: (context) => DetalleAbastecimientoBloc(locator<DetalleAbastecimientoUseCases>())),

  BlocProvider<LicenciaBloc>( create: (context) => LicenciaBloc(locator<LicenciaUseCases>())),

  BlocProvider<UserBloc>(create: (context) => UserBloc(locator<UserUseCases>())),

  BlocProvider<ArchivoBloc>(create: (context) => ArchivoBloc(locator<ArchivoUseCases>()),),

  BlocProvider<ZonaBloc>(create: (context) => ZonaBloc(locator<ZonaUseCases>())),

  BlocProvider<SedeBloc>(create: (context) => SedeBloc(locator<SedeUseCases>(),locator<ZonaUseCases>(),)), // Necesario para cargar zonas en el dropdown

  BlocProvider<GrifoBloc>(create: (context) => GrifoBloc(locator<GrifoUseCases>(),locator<SedeUseCases>())), // Necesario para cargar sedes en el dropdown

  BlocProvider<UnidadBloc>(create: (context) => UnidadBloc(locator<UnidadUseCases>())),

  BlocProvider<RolBloc>(create: (context) => RolBloc(locator<RolUseCases>()),),

  BlocProvider<ReporteBloc>(create: (context) => ReporteBloc(locator<ReporteUseCases>()),),

  BlocProvider<GpsBloc>(create: (context) => GpsBloc(gpsUseCases: locator<GpsUseCases>(),),),

  BlocProvider<ItinerarioBloc>(create: (context) => ItinerarioBloc(locator<ItinerarioUseCases>())),

  BlocProvider<RutaBloc>(create: (context) => RutaBloc(locator<RutaUseCases>())),
    
];
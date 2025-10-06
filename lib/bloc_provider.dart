import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/detalle_abastecimiento_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket_aprobacion/ticket_aprobacion_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/unidad/unidad_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/bloc/detalle_abastecimiento_bloc.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/bloc/ticket_aprobacion_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


List<BlocProvider> blocProviders = [

  BlocProvider<LoginBloc>(create: (context) => LoginBloc(locator<AuthUseCases>())),
  // InitEvent() solo se dispara cuando se muestra MainLoginPage
  BlocProvider<LocationBloc>(create: (context) => LocationBloc(locator<LocationUseCases>())),

  BlocProvider<TicketBloc>(create: (context) => TicketBloc(locator<TicketUseCases>(), locator<UnidadUseCases>())),

  BlocProvider<TicketAprobacionBloc>(create: (context) => TicketAprobacionBloc(locator<TicketAprobacionUseCases>())),

  BlocProvider<DetalleAbastecimientoBloc>(create: (context) => DetalleAbastecimientoBloc(locator<DetalleAbastecimientoUseCases>())),

];
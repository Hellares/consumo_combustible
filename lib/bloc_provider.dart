import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/ticket/ticket_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_bloc.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/bloc/ticket_bloc.dart';
// import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
// import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:syncronize/src/presentation/page/auth/login/empresa_user_roles/bloc/empresa_user_roles_bloc.dart';


List<BlocProvider> blocProviders = [

  // BlocProvider<LoginBloc>(create: (context) => LoginBloc(locator<AuthUseCases>()).. add(InitEvent())),
  BlocProvider<LoginBloc>(
  create: (context) => LoginBloc(locator<AuthUseCases>())
  // InitEvent() solo se dispara cuando se muestra MainLoginPage
  ),
  BlocProvider<LocationBloc>(
    create: (context) => LocationBloc(locator<LocationUseCases>())
  ),

  BlocProvider<TicketBloc>(
    create: (context) => TicketBloc(locator<TicketUseCases>())
  ),
];
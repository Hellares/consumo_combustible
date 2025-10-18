import 'package:consumo_combustible/bloc_provider.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:consumo_combustible/presentation/page/auth/login/main_login_page.dart';
import 'package:consumo_combustible/presentation/page/auth/rol_selection/role_selection_page.dart';
import 'package:consumo_combustible/presentation/page/detalle_abastecimiento/detalles_abastecimiento_page.dart';
import 'package:consumo_combustible/presentation/page/gps/admin/admin_tracking_page.dart';
import 'package:consumo_combustible/presentation/page/grifos/create_grifo_page.dart';
import 'package:consumo_combustible/presentation/page/grifos/edit_grifo_page.dart';
import 'package:consumo_combustible/presentation/page/grifos/grifos_list_page.dart';
import 'package:consumo_combustible/presentation/page/home_page.dart';
import 'package:consumo_combustible/presentation/page/licencias/licencias_page.dart';
import 'package:consumo_combustible/presentation/page/location/location_selection_page.dart';
import 'package:consumo_combustible/presentation/page/reportes/reportes_page.dart';
import 'package:consumo_combustible/presentation/page/rol/create_rol_page.dart';
import 'package:consumo_combustible/presentation/page/rol/roles_page.dart';
import 'package:consumo_combustible/presentation/page/sedes/create_sede_page.dart';
import 'package:consumo_combustible/presentation/page/sedes/sedes_list_page.dart';
import 'package:consumo_combustible/presentation/page/ticket_abastecimiento/create_ticket_page.dart';
import 'package:consumo_combustible/presentation/page/ticket_aprobacion/tickets_aprobacion_page.dart';
import 'package:consumo_combustible/presentation/page/unidad/crear_unidad_page.dart';
import 'package:consumo_combustible/presentation/page/unidad/unidades_list_page.dart';
import 'package:consumo_combustible/presentation/page/user/user_page.dart';
import 'package:consumo_combustible/presentation/page/zona/create_zona_page.dart';
import 'package:consumo_combustible/presentation/page/zona/zonas_list_page.dart';
import 'package:consumo_combustible/presentation/splash/splash_page.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// ✅ Configuración única de dependencias
Future<void> setupAppDependencies() async {
  if (kDebugMode) debugPrint("⚡ Configurando dependencias...");

  final stopwatch = Stopwatch()..start();

  try {
    // ✅ Injectable configura (incluyendo FastStorageService)
    await configureDependencies();

    stopwatch.stop();
    if (kDebugMode) {
      debugPrint(
        "✅ Dependencias configuradas en ${stopwatch.elapsedMilliseconds}ms",
      );
    }
  } catch (e) {
    stopwatch.stop();
    if (kDebugMode) {
      debugPrint(
        "❌ Error configurando dependencias (${stopwatch.elapsedMilliseconds}ms): $e",
      );
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) debugPrint("🚀 Iniciando app...");

  await setupAppDependencies();

  runApp(Phoenix(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          // ✅ Detectar logout exitoso
          if (state.response is Success) {
            final response = state.response as Success;
            if (response.data is String &&
                (response.data as String).contains('Sesión cerrada')) {
              if (kDebugMode) print('🔄 Logout exitoso - Reiniciando app...');

              WidgetsBinding.instance.addPostFrameCallback((_) {
                // ✅ Usar el context del widget Phoenix directamente
                Phoenix.rebirth(context);
              });
            }
          }
        },
        child: MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Combustible',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          builder: (context, child) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: child,
            );
          },
          initialRoute: 'splash',
          routes: {
            'splash': (context) => const SplashPage(),
            'login': (context) => const MainLoginPage(),
            'role-selection': (context) => const RoleSelectionPage(),
            'home': (context) => const HomePageAlternative(),
            'location-selection': (context) => const LocationSelectionPage(),
            'create-ticket': (context) => const CreateTicketPage(),
            'tickets-aprobacion': (context) => const TicketsAprobacionPage(),
            'detalles-abastecimiento': (context) => const DetallesAbastecimientoPage(),
            'licencias': (context) => const LicenciasPage(),
            'users': (context) => const UserPage(),
            'zonas': (context) => const ZonasListPage(),
            'create-zona': (context) => const CreateZonaPage(),
            'sedes': (context) => const SedesListPage(),
            'create-sede': (context) => const CreateSedePage(),
            'grifos': (context) => const GrifosListPage(),
            'create-grifo': (context) => const CreateGrifoPage(),
            'edit-grifo': (context) {
              final grifoId = ModalRoute.of(context)?.settings.arguments as int;
              return EditGrifoPage(grifoId: grifoId);
            },
            'unidades': (context) => const UnidadesListPage(),
            'crear-unidad': (context) => const CrearUnidadPage(),
            'roles': (context) => const RolesPage(),
            'create-rol': (context) => const CreateRolPage(),
            'edit-rol': (context) {
              final rol = ModalRoute.of(context)?.settings.arguments;
              return CreateRolPage(rolToEdit: rol as dynamic);
            },
            'reportes': (context) => const ReportesPage(),
            'gps-admin': (context) => const AdminTrackingPage(),
          },
        ),
      ),
    );
  }
}

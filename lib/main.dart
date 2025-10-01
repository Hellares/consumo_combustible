import 'package:consumo_combustible/bloc_provider.dart';
import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/presentation/page/auth/login/main_login_page.dart';
import 'package:consumo_combustible/presentation/page/home_page.dart';
import 'package:consumo_combustible/presentation/splash/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';


final getIt = GetIt.instance;

/// ✅ CONFIGURACIÓN ÚNICA Y SÚPER RÁPIDA
Future<void> setupAppDependencies() async {
  if (kDebugMode) debugPrint("⚡ Configurando dependencias (modo rápido)...");
  
  final stopwatch = Stopwatch()..start();
  
  try {
    // 1️⃣ Injectable (servicios principales) - SOLO UNA VEZ
    await configureDependencies();
    
    // 2️⃣ FastStorage - Reemplazar SecureStorageService lento
    if (!getIt.isRegistered<FastStorageService>()) {
      final fastStorage = FastStorageService();
      
      // Inicialización súper rápida en background
      fastStorage.initialize().catchError((e) {
        if (kDebugMode) debugPrint("⚠️ FastStorage init falló (no crítico): $e");
      });
      
      getIt.registerSingleton<FastStorageService>(fastStorage);
      
      if (kDebugMode) debugPrint("⚡ FastStorageService registrado");
    }
    
    stopwatch.stop();
    if (kDebugMode) {
      debugPrint("✅ Dependencias configuradas en ${stopwatch.elapsedMilliseconds}ms");
    }
    
  } catch (e) {
    stopwatch.stop();
    if (kDebugMode) {
      debugPrint("❌ Error configurando dependencias (${stopwatch.elapsedMilliseconds}ms): $e");
    }
    rethrow;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) debugPrint("🚀 Iniciando app (modo optimizado)...");
  
  // ✅ UNA SOLA configuración de dependencias
  await setupAppDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Combustible',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: 'splash',
        routes: {
          'splash': (context) => const SplashPage(),
          'login': (context) => const MainLoginPage(),
          'home': (context) => const HomePageAlternative(),
          
        },
      ),
    );
  }
}


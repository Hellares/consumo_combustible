import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/cliente_login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';


class MainLoginPage extends StatefulWidget {
  const MainLoginPage({super.key});

  @override
  State<MainLoginPage> createState() => _MainLoginPageState();

  
}


class _MainLoginPageState extends State<MainLoginPage> {
  @override
void initState() {
  super.initState();
  // Solo inicializar cuando realmente se muestra el login
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<LoginBloc>().add(const InitEvent());
  });
}
  @override
  Widget build(BuildContext context) {
    _transparentBar();

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: GradientContainer(
        gradient: AppGradients.custom(
          startColor: AppColors.white, 
          middleColor: AppColors.white,
          endColor: const Color.fromARGB(255, 175, 213, 250),
          stops: [0.0, 0.5, 1.0],
        ),
        height: double.infinity,
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0,),
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // Cambiado a min para no expandir infinitamente
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const SizedBox(height: 20),
                    _buildWelcomeText(),
                    const SizedBox(height: 50),
                    _buildLogoSection(),
                    const SizedBox(height: 30),
                    _buildContent(),
                    const SizedBox(height: 220),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _transparentBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Bienvenido',
        style: AppFont.airstrikeBold3d.style(
          fontSize: 24,
          color: AppColors.blue3,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          'assets/img/6.svg',
          height: 150,
          width: 150,
        ),
        // Image.asset(
        //   height: 150,
        //   width: 150,
        //   fit: BoxFit.contain,
        // ),
        const SizedBox(height: 18),
        Text(
          'Sistema de Control de Combustible',
          style: AppFont.orbitronMedium.style(
            fontSize: 14,
            color: AppColors.blue3,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return const ClienteLoginPage(); // Solo muestra la página de cliente
  }
}
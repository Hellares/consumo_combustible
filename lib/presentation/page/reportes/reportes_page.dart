// lib/presentation/page/reportes/reportes_page.dart

import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/core/widgets/appbar/smart_appbar.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/data/api/api_config.dart';
import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/domain/use_cases/reporte/reporte_use_cases.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_bloc.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_event.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_state.dart';
import 'package:consumo_combustible/presentation/page/reportes/widgets/filtros_reporte_widget.dart';
import 'package:consumo_combustible/presentation/page/reportes/widgets/resumen_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  @override
  void initState() {
    super.initState();
    // Cargar resumen al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReporteBloc>().add(const ObtenerResumenEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: SmartAppBar.withUser(
        title: 'Reportes',
        showLogo: true,
        logoPath: ApiConfig.logoPath,
      ),
      body: BlocProvider(
        create: (context) => ReporteBloc(locator<ReporteUseCases>())
          ..add(const ObtenerResumenEvent()),
        child: BlocListener<ReporteBloc, ReporteState>(
          listener: _handleBlocListener,
          child: GradientContainer(
            gradient: AppGradients.sinfondo,
            child: Column(
              children: [
                // Resumen del sistema
                BlocBuilder<ReporteBloc, ReporteState>(
                  builder: (context, state) {
                    if (state.resumenResponse is Loading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state.resumen != null) {
                      return ResumenCard(resumen: state.resumen!);
                    }

                    return const SizedBox.shrink();
                  },
                ),

                // Título de filtros
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppTitle(
                      'Generar Reporte',
                      fontSize: 7,
                      color: AppColors.blue3,
                    ),
                  ),
                ),

                // Formulario de filtros
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FiltrosReporteWidget(
                      onGenerarReporte: _onGenerarReporte,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Listener del BLoC para mostrar snackbars y abrir archivos
  void _handleBlocListener(BuildContext context, ReporteState state) {
    // Éxito al exportar
    if (state.exportarResponse is Success<DescargaArchivoResponse>) {
      final response =
          (state.exportarResponse as Success<DescargaArchivoResponse>).data;

      SnackBarHelper.showSuccess(
        context,
        '✓ Reporte descargado: ${response.nombreArchivo}',
      );

      // Preguntar si desea abrir el archivo
      _mostrarDialogoAbrirArchivo(context, response.rutaArchivo!);

      // Limpiar estado
      context.read<ReporteBloc>().add(const ClearReporteMessagesEvent());
    }

    // Error al exportar
    if (state.exportarResponse is Error) {
      final error = state.exportarResponse as Error;
      SnackBarHelper.showError(context, error.message);

      // Limpiar estado
      context.read<ReporteBloc>().add(const ClearReporteMessagesEvent());
    }

    // Éxito al obtener datos
    if (state.datosResponse is Success<ReporteResponse>) {
      final response = (state.datosResponse as Success<ReporteResponse>).data;

      SnackBarHelper.showSuccess(
        context,
        '✓ ${response.totalRegistros} registros encontrados',
      );
    }

    // Error al obtener datos
    if (state.datosResponse is Error) {
      final error = state.datosResponse as Error;
      SnackBarHelper.showError(context, error.message);
    }
  }

  /// Callback cuando se genera un reporte
  void _onGenerarReporte(FiltrosReporte filtros) {
    context.read<ReporteBloc>().add(ExportarReporteEvent(filtros));
  }

  /// Mostrar diálogo para abrir el archivo descargado
  void _mostrarDialogoAbrirArchivo(BuildContext context, String rutaArchivo) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          '¿Abrir archivo?',
          style: AppFont.pirulentBold.style(fontSize: 6, color: AppColors.blue3),
        ),
        content: Text(
          'El reporte se ha descargado exitosamente. ¿Deseas abrirlo ahora?',
          style: TextStyle(fontSize: 5, color: AppColors.blue3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Más tarde',
              style: TextStyle(fontSize: 5, color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _abrirArchivo(rutaArchivo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue3,
            ),
            child: Text(
              'Abrir',
              style: TextStyle(fontSize: 5, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Abrir archivo con la app predeterminada del sistema
  Future<void> _abrirArchivo(String rutaArchivo) async {
    try {
      final result = await OpenFilex.open(rutaArchivo);

      if (result.type != ResultType.done && mounted) {
        SnackBarHelper.showError(
          context,
          'No se pudo abrir el archivo: ${result.message}',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Error al abrir el archivo: $e',
        );
      }
    }
  }
}
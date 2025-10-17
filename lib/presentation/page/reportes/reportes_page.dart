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
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_bloc.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_event.dart';
import 'package:consumo_combustible/presentation/page/reportes/bloc/reporte_state.dart';
import 'package:consumo_combustible/presentation/page/reportes/widgets/filtros_reporte_widget.dart';
import 'package:consumo_combustible/presentation/page/reportes/widgets/resumen_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportesPage extends StatefulWidget {
  const ReportesPage({super.key});

  @override
  State<ReportesPage> createState() => _ReportesPageState();
}

class _ReportesPageState extends State<ReportesPage> {
  // Variable para controlar si ya se mostró el diálogo
  bool _dialogoMostrado = false;

  @override
  void initState() {
    super.initState();
    // Cargar resumen al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReporteBloc>().add(const ObtenerResumenEvent());
      // Limpiar mensajes pendientes al entrar a la página
      context.read<ReporteBloc>().add(const ClearReporteMessagesEvent());
    });
  }

  @override
  void dispose() {
    // Resetear el flag al salir de la página
    _dialogoMostrado = false;
    super.dispose();
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
      body: BlocListener<ReporteBloc, ReporteState>(
        listenWhen: (previous, current) {
          // Solo escuchar cambios reales en las respuestas
          return previous.exportarResponse != current.exportarResponse ||
                 previous.datosResponse != current.datosResponse;
        },
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
                    fontSize: 9,
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
    );
  }

  /// Listener del BLoC para mostrar snackbars y abrir archivos
  void _handleBlocListener(BuildContext context, ReporteState state) {
    // Éxito al exportar
    if (state.exportarResponse is Success<DescargaArchivoResponse> && !_dialogoMostrado) {
      final response =
          (state.exportarResponse as Success<DescargaArchivoResponse>).data;

      SnackBarHelper.showSuccess(
        context,
        '✓ Reporte descargado: ${response.nombreArchivo}',
      );

      // Marcar que el diálogo se va a mostrar
      _dialogoMostrado = true;

      // Preguntar si desea abrir el archivo
      _mostrarDialogoAbrirArchivo(context, response.rutaArchivo!);

      // Limpiar estado de forma segura
      _limpiarEstadoSeguro();
    }

    // Error al exportar
    if (state.exportarResponse is Error) {
      final error = state.exportarResponse as Error;
      SnackBarHelper.showError(context, error.message);

      // Limpiar estado
      context.read<ReporteBloc>().add(const ClearReporteMessagesEvent());
    }

    // Mostrar mensaje de permisos si es necesario
    if (state.exportarResponse is Error) {
      final error = state.exportarResponse as Error;
      if (error.message.contains('Permisos de almacenamiento denegados')) {
        // Mostrar diálogo adicional para permisos
        _mostrarDialogoPermisos(context);
      }
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
      barrierDismissible: false, // Evitar cerrar tocando fuera
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.blue3.withValues(alpha: 0.3), width: 1.5),
        ),
        title: Text(
          '¿Abrir archivo?',
          style: AppFont.oxygenRegular.style(fontSize: 10, color: AppColors.blue3),
        ),
        content: Text(
          'El reporte se ha descargado exitosamente. ¿Deseas abrirlo ahora?',
          style: TextStyle(fontSize: 10, color: AppColors.blue3),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Resetear el flag cuando se cierra el diálogo
              _dialogoMostrado = false;
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(70, 30),
            ),
            child: Text(
              'Más tarde',
              style: TextStyle(fontSize: 10, color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Resetear el flag cuando se cierra el diálogo
              _dialogoMostrado = false;
              _abrirArchivo(rutaArchivo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue3,
              elevation: 0,
              minimumSize: const Size(70, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Abrir',
              style: TextStyle(fontSize: 10, color: AppColors.white),
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

  /// Mostrar diálogo para solicitar permisos de almacenamiento
  void _mostrarDialogoPermisos(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Permisos requeridos',
          style: AppFont.pirulentBold.style(fontSize: 6, color: AppColors.blue3),
        ),
        content: Text(
          'La aplicación necesita permisos de almacenamiento para guardar los reportes descargados. ¿Deseas abrir la configuración de permisos?',
          style: TextStyle(fontSize: 5, color: AppColors.blue3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: 5, color: AppColors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Abrir configuración de la app
              await openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue3,
            ),
            child: Text(
              'Abrir configuración',
              style: TextStyle(fontSize: 5, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Limpiar estado del BLoC de forma segura
  void _limpiarEstadoSeguro() {
    // Usar addPostFrameCallback para asegurar que el widget está montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ReporteBloc>().add(const ClearReporteMessagesEvent());
      }
    });
  }
}
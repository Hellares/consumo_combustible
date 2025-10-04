import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/app_gradients.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_bloc.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_event.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  late final LocationBloc _bloc;
  int _currentStep = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LocationBloc>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Si viene de cambiar ubicación (canPop = true), limpiar selección
      if (Navigator.of(context).canPop()) {
        // Cambio de ubicación - empezar desde cero
        _bloc.add(const ClearLocation());
      } else {
        // Flujo inicial - cargar ubicación guardada si existe
        _bloc.add(const LoadSavedLocation());
      }

      // Siempre cargar zonas
      _bloc.add(const LoadZonas());
    });
  }

  Future<void> _handleSaveAndNavigate() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    // Guardar ubicación
    _bloc.add(const SaveLocation());

    // Esperar a que se guarde
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // ✅ Verificar si puede hacer pop (hay algo en el stack)
    if (Navigator.of(context).canPop()) {
      // Viene de home o ticket page - hacer pop normal
      Navigator.of(context).pop(true);
    } else {
      // Viene del flujo inicial (splash) - navegar a home
      Navigator.of(context).pushNamedAndRemoveUntil('home', (route) => false);
    }
  }

  /// ✅ Validar si puede continuar en el paso actual
  bool _canContinueCurrentStep(LocationState state) {
    switch (_currentStep) {
      case 0:
        // Paso 1: Debe tener zona seleccionada
        return state.selectedZona != null;
      case 1:
        // Paso 2: Debe tener sede seleccionada
        return state.selectedSede != null;
      case 2:
        // Paso 3: Debe tener grifo seleccionado
        return state.selectedGrifo != null;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      gradient: AppGradients.custom(
        // startColor: AppColors.white,
        // middleColor: AppColors.white,
        // endColor: const Color.fromARGB(255, 175, 213, 250),
        startColor: const Color.fromARGB(255, 175, 213, 250),
        middleColor: AppColors.white,
        endColor: AppColors.white,
        stops: [0.0, 0.5, 1.0],
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AppHeadingText(
            'Seleccionar Ubicación',
            font: AppFont.pirulentBold,
            fontSize: 10,
          ),
          actions: [
            // Botón para limpiar selección
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _bloc.add(const ClearLocation());
                _bloc.add(const LoadZonas());
                setState(() => _currentStep = 0);
              },
            ),
          ],
        ),
        body: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            // ✅ Validar si puede continuar en cada paso
            final canContinue = _canContinueCurrentStep(state);

            return Stepper(
              currentStep: _currentStep,
              onStepContinue: (_isSaving || !canContinue)
                  ? null
                  : () async {
                      if (_currentStep < 2) {
                        setState(() => _currentStep++);
                      } else {
                        // ✅ Último paso - guardar y navegar
                        await _handleSaveAndNavigate();
                      }
                    },
              onStepCancel: _isSaving
                  ? null
                  : () {
                      if (_currentStep > 0) {
                        setState(() => _currentStep--);
                      } else {
                        Navigator.of(context).pop(false);
                      }
                    },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: (_isSaving || !canContinue)
                            ? null
                            : details.onStepContinue,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_currentStep == 2 ? 'Guardar' : 'Continuar'),
                      ),
                      const SizedBox(width: 8),
                      if (_currentStep > 0 || Navigator.of(context).canPop())
                        TextButton(
                          onPressed: _isSaving ? null : details.onStepCancel,
                          child: Text(_currentStep > 0 ? 'Atrás' : 'Cancelar'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // STEP 1: Seleccionar Zona
                Step(
                  title: AppTitle(
                    'Zona',
                    font: AppFont.pirulentBold,
                    fontSize: 10,
                  ),
                  stepStyle: AppStepStyles.defaultStyle,
                  content: _buildZonasStep(state),
                  isActive: _currentStep >= 0,
                  state: state.selectedZona != null
                      ? StepState.complete
                      : StepState.indexed,
                ),

                // STEP 2: Seleccionar Sede
                Step(
                  title: AppTitle(
                    'Sede',
                    font: AppFont.pirulentBold,
                    fontSize: 10,
                  ),
                  stepStyle: AppStepStyles.defaultStyle,
                  content: _buildSedesStep(state),
                  isActive: _currentStep >= 1,
                  state: state.selectedSede != null
                      ? StepState.complete
                      : StepState.indexed,
                ),

                // STEP 3: Seleccionar Grifo
                Step(
                  title: AppTitle(
                    'Grifo',
                    font: AppFont.pirulentBold,
                    fontSize: 10,
                  ),
                  stepStyle: AppStepStyles.defaultStyle,
                  content: _buildGrifosStep(state),
                  isActive: _currentStep >= 2,
                  state: state.selectedGrifo != null
                      ? StepState.complete
                      : StepState.indexed,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildZonasStep(LocationState state) {
    // ✅ Mostrar loading si está cargando O si está en estado inicial
    if (state.zonasResponse is Loading || state.zonasResponse is Initial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.zonasResponse is Success) {
      final zonas = (state.zonasResponse as Success).data as List<Zona>;

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: zonas.length,
        itemBuilder: (context, index) {
          final zona = zonas[index];
          final isSelected = state.selectedZona?.id == zona.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => _bloc.add(SelectZona(zona)),
              child: GradientContainer(
                height: 60,
                gradient: AppGradients.fondopollo,
                borderColor: isSelected
                    ? AppColors.blue3
                    : const Color.fromARGB(255, 197, 197, 197),
                borderWidth: isSelected ? 1.0 : 0.5,
                shadowStyle: isSelected
                    ? ShadowStyle.glow
                    : ShadowStyle.colorful,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Leading Icon
                    Icon(
                      Icons.location_on,
                      color: isSelected ? AppColors.blue3 : null,
                    ),
                    const SizedBox(width: 16),
                    // Title y Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTitle(zona.nombre),
                          const SizedBox(height: 2),
                          AppSubtitle(
                            '${zona.sedesCount} sedes • ${zona.unidadesCount} unidades',
                            color: AppColors.orange,
                          ),
                        ],
                      ),
                    ),

                    // Trailing Icon
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.blue3),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Solo mostrar error si realmente hay un error
    if (state.zonasResponse is Error) {
      final error = (state.zonasResponse as Error).message;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _bloc.add(const LoadZonas()),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSedesStep(LocationState state) {
    if (state.selectedZona == null) {
      return const Center(
        child: Text(
          'Selecciona una zona primero',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // ✅ Mostrar loading si está cargando O en estado inicial
    if (state.sedesResponse is Loading || state.sedesResponse is Initial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.sedesResponse is Success) {
      final sedes = (state.sedesResponse as Success).data as List<Sede>;

      if (sedes.isEmpty) {
        return const Center(
          child: Text(
            'No hay sedes disponibles en esta zona',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sedes.length,
        itemBuilder: (context, index) {
          final sede = sedes[index];
          final isSelected = state.selectedSede?.id == sede.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => _bloc.add(SelectSede(sede)),
              child: GradientContainer(
                height: 70,
                gradient: AppGradients.fondopollo,
                borderColor: isSelected
                    ? AppColors.green
                    : const Color.fromARGB(255, 197, 197, 197),
                borderWidth: isSelected ? 1.0 : 0.5,
                shadowStyle: isSelected
                    ? ShadowStyle.glow
                    : ShadowStyle.colorful,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Leading Icon
                    Icon(
                      Icons.business,
                      color: isSelected ? AppColors.green : null,
                    ),
                    const SizedBox(width: 16),
                    // Title y Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTitle(sede.nombre),
                          const SizedBox(height: 2),
                          AppSubtitle(
                            sede.direccion.toString(),
                            color: AppColors.orange,
                          ),
                          const SizedBox(height: 2),
                          AppSubtitle(
                            '${sede.grifosCount} grifos disponibles',
                            color: AppColors.orange,
                          ),
                        ],
                      ),
                    ),
                    // Trailing Icon
                    if (isSelected)
                      const Icon(Icons.check_circle, color: AppColors.green),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Error real
    if (state.sedesResponse is Error) {
      final error = (state.sedesResponse as Error).message;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _bloc.add(LoadSedesByZona(state.selectedZona!.id)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildGrifosStep(LocationState state) {
    if (state.selectedSede == null) {
      return const Center(
        child: Text(
          'Selecciona una sede primero',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // ✅ Mostrar loading si está cargando O en estado inicial
    if (state.grifosResponse is Loading || state.grifosResponse is Initial) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.grifosResponse is Success) {
      final grifos = (state.grifosResponse as Success).data as List<Grifo>;

      if (grifos.isEmpty) {
        return const Center(
          child: Text(
            'No hay grifos disponibles en esta sede',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grifos.length,
        itemBuilder: (context, index) {
          final grifo = grifos[index];
          final isSelected = state.selectedGrifo?.id == grifo.id;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: GestureDetector(
              onTap: () => _bloc.add(SelectGrifo(grifo)),
              child: GradientContainer(
                height: 85,
                gradient: AppGradients.fondopollo,
                borderColor: isSelected
                    ? Colors.orange
                    : const Color.fromARGB(255, 197, 197, 197),
                borderWidth: isSelected ? 1.0 : 0.5,
                shadowStyle: isSelected
                    ? ShadowStyle.glow
                    : ShadowStyle.colorful,
                borderRadius: BorderRadius.circular(8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    // Leading Icon
                    Icon(
                      Icons.local_gas_station,
                      color: isSelected ? AppColors.green : null,
                    ),
                    const SizedBox(width: 16),
                    // Title y Subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTitle(grifo.nombre),
                          const SizedBox(height: 2),
                          AppSubtitle(
                            grifo.direccion.toString(),
                            color: AppColors.orange,
                          ),
                          const SizedBox(height: 2),
                          AppSubtitle(
                            '${grifo.horarioApertura} - ${grifo.horarioCierre}',
                            color: AppColors.orange,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            grifo.estaAbierto ? 'Abierto ahora' : 'Cerrado', style: TextStyle(fontSize: 10,color: grifo.estaAbierto ? AppColors.green : AppColors.red),) ,
                     
                        ],
                      ),
                    ),
                    // Trailing Icon
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Colors.orange),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Error real
    if (state.grifosResponse is Error) {
      final error = (state.grifosResponse as Error).message;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  _bloc.add(LoadGrifosBySede(state.selectedSede!.id)),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }
}

class AppStepStyles {
  static StepStyle get defaultStyle =>
      StepStyle(color: AppColors.blue2, connectorColor: AppColors.orange);
}

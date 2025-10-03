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

  @override
  void initState() {
    super.initState();
    _bloc = context.read<LocationBloc>();

    // Cargar ubicación guardada o zonas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(const LoadSavedLocation());
      _bloc.add(const LoadZonas());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Ubicación'),
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
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state.saveResponse is Success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              'home',
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          return Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _bloc.add(const SaveLocation());
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: [
              // STEP 1: Seleccionar Zona
              Step(
                title: const Text('Zona'),
                content: _buildZonasStep(state),
                isActive: _currentStep >= 0,
                state: state.selectedZona != null
                    ? StepState.complete
                    : StepState.indexed,
              ),

              // STEP 2: Seleccionar Sede
              Step(
                title: const Text('Sede'),
                content: _buildSedesStep(state),
                isActive: _currentStep >= 1,
                state: state.selectedSede != null
                    ? StepState.complete
                    : StepState.indexed,
              ),

              // STEP 3: Seleccionar Grifo
              Step(
                title: const Text('Grifo'),
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
    );
  }

  Widget _buildZonasStep(LocationState state) {
    if (state.zonasResponse is Loading) {
      return const Center(child: CircularProgressIndicator());
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

          return Card(
            color: isSelected ? Colors.blue.shade50 : null,
            child: ListTile(
              leading: Icon(
                Icons.location_on,
                color: isSelected ? Colors.blue : null,
              ),
              title: Text(zona.nombre),
              subtitle: Text(
                '${zona.sedesCount} sedes • ${zona.unidadesCount} unidades',
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.blue)
                  : null,
              onTap: () => _bloc.add(SelectZona(zona)),
            ),
          );
        },
      );
    }

    return const Text('Error cargando zonas');
  }

  Widget _buildSedesStep(LocationState state) {
    if (state.selectedZona == null) {
      return const Text('Selecciona una zona primero');
    }

    if (state.sedesResponse is Loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.sedesResponse is Success) {
      final sedes = (state.sedesResponse as Success).data as List<Sede>;

      if (sedes.isEmpty) {
        return const Text('No hay sedes disponibles en esta zona');
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sedes.length,
        itemBuilder: (context, index) {
          final sede = sedes[index];
          final isSelected = state.selectedSede?.id == sede.id;

          return Card(
            color: isSelected ? Colors.green.shade50 : null,
            child: ListTile(
              leading: Icon(
                Icons.business,
                color: isSelected ? Colors.green : null,
              ),
              title: Text(sede.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sede.direccion.toString()),
                  Text('${sede.grifosCount} grifos disponibles'),
                ],
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => _bloc.add(SelectSede(sede)),
            ),
          );
        },
      );
    }

    return const Text('Error cargando sedes');
  }

  Widget _buildGrifosStep(LocationState state) {
    if (state.selectedSede == null) {
      return const Text('Selecciona una sede primero');
    }

    if (state.grifosResponse is Loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.grifosResponse is Success) {
      final grifos = (state.grifosResponse as Success).data as List<Grifo>;

      if (grifos.isEmpty) {
        return const Text('No hay grifos disponibles en esta sede');
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grifos.length,
        itemBuilder: (context, index) {
          final grifo = grifos[index];
          final isSelected = state.selectedGrifo?.id == grifo.id;

          return Card(
            color: isSelected ? Colors.orange.shade50 : null,
            child: ListTile(
              leading: Icon(
                Icons.local_gas_station,
                color: isSelected ? Colors.orange : null,
              ),
              title: Text(grifo.nombre),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(grifo.direccion),
                  Text('${grifo.horarioApertura} - ${grifo.horarioCierre}'),
                  Text(
                    grifo.estaAbierto ? 'Abierto ahora' : 'Cerrado',
                    style: TextStyle(
                      color: grifo.estaAbierto ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.orange)
                  : null,
              onTap: () => _bloc.add(SelectGrifo(grifo)),
            ),
          );
        },
      );
    }

    return const Text('Error cargando grifos');
  }
}

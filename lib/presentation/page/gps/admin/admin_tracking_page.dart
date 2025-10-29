import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_bloc.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_event.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_state.dart';
import 'package:consumo_combustible/presentation/page/gps/admin/widgets/admin_map_widget.dart';
import 'package:consumo_combustible/presentation/page/gps/admin/widgets/units_list_panel.dart';
import 'package:consumo_combustible/presentation/page/gps/admin/widgets/tracking_stats_widget.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';

class AdminTrackingPage extends StatefulWidget {
  const AdminTrackingPage({super.key});

  @override
  State<AdminTrackingPage> createState() => _AdminTrackingPageState();
}

class _AdminTrackingPageState extends State<AdminTrackingPage> {
  final GlobalKey<AdminMapWidgetState> _mapKey = GlobalKey<AdminMapWidgetState>();
  int? _selectedUnitId;
  Timer? _refreshTimer;
  GpsBloc? _gpsBloc;
  bool _isWebSocketConnected = false;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _initializeTracking();

    // Auto-refresh cada 30 segundos
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) => _refreshLocations(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _gpsBloc ??= context.read<GpsBloc>();
  }

  Future<void> _initializeTracking() async {
    // Obtener token
    final authUseCases = locator<AuthUseCases>();
    final session = await authUseCases.getUserSession.run();

    if (session?.data?.accessToken == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay sesión activa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _authToken = session!.data!.accessToken;
    if (!mounted) return;

    // ✅ CORRECCIÓN: Primero cargar ubicaciones REST
    // El listener se encargará de conectar el WebSocket cuando las ubicaciones estén cargadas
    context.read<GpsBloc>().add(const LoadCurrentLocationsEvent());
  }

  void _refreshLocations() {
    if (!mounted) return;
    context.read<GpsBloc>().add(const LoadCurrentLocationsEvent());
  }

  void _onUnitSelected(int unidadId) {
    setState(() {
      _selectedUnitId = unidadId;
    });
    _mapKey.currentState?.centerOnUnit(unidadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo GPS - Admin', style: TextStyle(fontSize: 12)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 18,),
            onPressed: _refreshLocations,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, size: 18,),
            onPressed: _showFilters,
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: BlocConsumer<GpsBloc, GpsState>(
        listener: (context, state) {
          // ✅ CORRECCIÓN: Conectar WebSocket después de cargar ubicaciones
          if (state is GpsLocationsLoaded && !_isWebSocketConnected && _authToken != null) {
            _isWebSocketConnected = true;
            // ✅ Capturar BLoC antes del async gap
            final bloc = context.read<GpsBloc>();
            // Conectar con auto-suscripción después de que las ubicaciones estén cargadas
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                bloc.add(
                  ConnectWebSocketEvent(_authToken!, autoSubscribe: true),
                );
              }
            });
          }
          
          if (state is GpsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        // ✅ OPTIMIZACIÓN: Solo reconstruir cuando cambien las ubicaciones
        buildWhen: (previous, current) {
          // Reconstruir si:
          // 1. Cambia de/a estado de loading
          if (current is GpsLoadingLocations || previous is GpsLoadingLocations) {
            return true;
          }
          
          // 2. Se cargan ubicaciones nuevas
          if (current is GpsLocationsLoaded) {
            return true;
          }
          
          // 3. Llegan actualizaciones del WebSocket
          if (current is GpsReceivingUpdates) {
            // Solo reconstruir si cambió el número de unidades o sus datos
            if (previous is GpsReceivingUpdates) {
              // Comparar si realmente cambió algo relevante
              return current.unidades.length != previous.unidades.length ||
                     current.lastUpdate != previous.lastUpdate;
            }
            return true;
          }
          
          // 4. Hay un error
          if (current is GpsError) {
            return true;
          }
          
          // Para otros estados, no reconstruir
          return false;
        },
        builder: (context, state) {
          List<UnidadTracking> unidades = [];

          // ✅ CORRECCIÓN: Priorizar GpsReceivingUpdates que ahora contiene
          // todas las unidades (activas e inactivas)
          if (state is GpsReceivingUpdates) {
            unidades = state.unidades;
          } else if (state is GpsLocationsLoaded) {
            unidades = state.data.data;
          }

          return Column(
            children: [
              TrackingStatsWidget(unidades: unidades),
              Expanded(
                child: Row(
                  children: [
                    // ✅ Reducido de 300 a 250 para dar más espacio al mapa
                    SizedBox(
                      width: 205,
                      child: UnitsListPanel(
                        unidades: unidades,
                        selectedUnitId: _selectedUnitId,
                        onUnitSelected: _onUnitSelected,
                        onRefresh: _refreshLocations,
                      ),
                    ),
                    Expanded(child: _buildMapSection(state, unidades)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMapSection(GpsState state, List<UnidadTracking> unidades) {
    if (state is GpsLoadingLocations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (unidades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay unidades con ubicación',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Las unidades aparecerán aquí cuando envíen su ubicación',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: AdminMapWidget(
        key: _mapKey,
        unidades: unidades,
        onUnitTapped: _onUnitSelected,
      ),
    );
  }

  void _showFilters() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros próximamente')),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _gpsBloc?.add(const DisconnectWebSocketEvent());
    super.dispose();
  }
}

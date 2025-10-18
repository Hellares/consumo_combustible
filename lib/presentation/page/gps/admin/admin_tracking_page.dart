// =============================================
// Admin Tracking Page
// Página principal de monitoreo GPS para Admin
// =============================================

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
  // ✅ Ahora sin guion bajo
  final GlobalKey<AdminMapWidgetState> _mapKey = GlobalKey<AdminMapWidgetState>();
  int? _selectedUnitId;
  Timer? _refreshTimer;

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

  Future<void> _initializeTracking() async {
    // Obtener token
    final authUseCases = locator<AuthUseCases>();
    final session = await authUseCases.getUserSession.run();
    
    if (session?.data?.token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay sesión activa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final token = session!.data!.token;

    if (!mounted) return;

    // Conectar al WebSocket
    context.read<GpsBloc>().add(ConnectWebSocketEvent(token));
    
    // Esperar un momento y suscribirse a todas las unidades
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    context.read<GpsBloc>().add(const SubscribeToAllUnitsEvent());
    
    // Cargar ubicaciones actuales
    _refreshLocations();
  }

  void _refreshLocations() {
    if (!mounted) return;
    context.read<GpsBloc>().add(const LoadCurrentLocationsEvent());
  }

  void _onUnitSelected(int unidadId) {
    setState(() {
      _selectedUnitId = unidadId;
    });
    
    // ✅ Centrar mapa en la unidad
    _mapKey.currentState?.centerOnUnit(unidadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monitoreo GPS - Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLocations,
            tooltip: 'Actualizar',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filtros',
          ),
        ],
      ),
      body: BlocConsumer<GpsBloc, GpsState>(
        listener: (context, state) {
          if (state is GpsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Obtener lista de unidades
          List<UnidadTracking> unidades = [];
          
          if (state is GpsReceivingUpdates) {
            unidades = state.unidades;
          } else if (state is GpsLocationsLoaded) {
            unidades = state.data.data;
          }

          return Column(
            children: [
              // Estadísticas
              TrackingStatsWidget(unidades: unidades),
              
              // Contenido principal
              Expanded(
                child: Row(
                  children: [
                    // Panel lateral con lista de unidades
                    SizedBox(
                      width: 300,
                      child: UnitsListPanel(
                        unidades: unidades,
                        selectedUnitId: _selectedUnitId,
                        onUnitSelected: _onUnitSelected,
                        onRefresh: _refreshLocations,
                      ),
                    ),
                    
                    // Mapa
                    Expanded(
                      child: _buildMapSection(state, unidades),
                    ),
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (unidades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay unidades con ubicación',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las unidades aparecerán aquí cuando envíen su ubicación',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AdminMapWidget(
        key: _mapKey,
        unidades: unidades,
        onUnitTapped: _onUnitSelected,
      ),
    );
  }

  void _showFilters() {
    // TODO: Implementar filtros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtros próximamente')),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    
    // Desconectar WebSocket
    context.read<GpsBloc>().add(const DisconnectWebSocketEvent());
    
    super.dispose();
  }
}
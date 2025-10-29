// lib/presentation/page/ruta_map/ruta_map_page.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/theme/gradient_container.dart';
import 'package:consumo_combustible/domain/models/mapa_ruta_data.dart';

import 'package:consumo_combustible/domain/models/tipo_visualizacion_ruta.dart';

import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_bloc.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_event.dart';
import 'package:consumo_combustible/presentation/page/itinerario/bloc/itinerario_state.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_bloc.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_event.dart';
import 'package:consumo_combustible/presentation/page/ruta/bloc/ruta_state.dart';
import 'package:consumo_combustible/presentation/page/ruta_map/widgets/mapa_widget.dart';
import 'package:consumo_combustible/presentation/page/ruta_map/widgets/resumen_ruta_widget.dart';
import 'package:consumo_combustible/presentation/page/ruta_map/widgets/tramos_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RutaMapPage extends StatefulWidget {
  final int ticketId;
  final int? itinerarioId;
  final int? rutaId;
  final String placaUnidad;
  final TipoVisualizacionRuta tipoVisualizacion;

  const RutaMapPage({
    super.key,
    required this.ticketId,
    this.itinerarioId,
    this.rutaId,
    required this.placaUnidad,
    required this.tipoVisualizacion,
  });

  @override
  State<RutaMapPage> createState() => _RutaMapPageState();
}

class _RutaMapPageState extends State<RutaMapPage> {
  MapaRutaData? _mapaData;

  @override
  void initState() {
    super.initState();
    _loadRutaData();
  }

  /// Cargar datos de la ruta o itinerario
  void _loadRutaData() {
    if (widget.tipoVisualizacion == TipoVisualizacionRuta.itinerario &&
        widget.itinerarioId != null) {
      // Cargar itinerario con tramos
      context.read<ItinerarioBloc>().add(
            LoadItinerarioById(widget.itinerarioId!),
          );
    } else if (widget.tipoVisualizacion == TipoVisualizacionRuta.rutaSimple &&
        widget.rutaId != null) {
      // Cargar ruta simple
      context.read<RutaBloc>().add(
            LoadRutaById(widget.rutaId!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ruta - ${widget.placaUnidad}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Ticket #${widget.ticketId}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: AppColors.blue3,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRutaData,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: widget.tipoVisualizacion == TipoVisualizacionRuta.itinerario
          ? _buildItinerarioView()
          : _buildRutaSimpleView(),
    );
  }

  /// Vista para itinerario
  Widget _buildItinerarioView() {
    return BlocBuilder<ItinerarioBloc, ItinerarioState>(
      builder: (context, state) {
        // Loading
        if (state.isLoadingDetalle) {
          return _buildLoadingView();
        }

        // Error
        if (state.hasDetalleError) {
          return _buildErrorView(state.detalleErrorMessage ?? 'Error desconocido');
        }

        // Success
        if (state.hasDetalle && state.itinerarioDetalle != null) {
          final itinerario = state.itinerarioDetalle!;

          // Crear MapaRutaData
          _mapaData ??= MapaRutaData(
              tipoVisualizacion: TipoVisualizacionRuta.itinerario,
              itinerario: itinerario,
              ticketId: widget.ticketId,
              placaUnidad: widget.placaUnidad,
            );

          return _buildMapaContent(_mapaData!);
        }

        // Initial state
        return _buildLoadingView();
      },
    );
  }

  /// Vista para ruta simple
  Widget _buildRutaSimpleView() {
    return BlocBuilder<RutaBloc, RutaState>(
      builder: (context, state) {
        // Loading
        if (state.isLoadingDetalle) {
          return _buildLoadingView();
        }

        // Error
        if (state.hasDetalleError) {
          return _buildErrorView(state.detalleErrorMessage ?? 'Error desconocido');
        }

        // Success
        if (state.hasDetalle && state.rutaDetalle != null) {
          final ruta = state.rutaDetalle!;

          // Crear MapaRutaData
          _mapaData ??= MapaRutaData(
              tipoVisualizacion: TipoVisualizacionRuta.rutaSimple,
              ruta: ruta,
              ticketId: widget.ticketId,
              placaUnidad: widget.placaUnidad,
            );

          return _buildMapaContent(_mapaData!);
        }

        // Initial state
        return _buildLoadingView();
      },
    );
  }

  /// Construir contenido del mapa
  Widget _buildMapaContent(MapaRutaData data) {
    if (data.tieneDatosValidos == false) {
      return _buildErrorView('No hay datos válidos para mostrar en el mapa');
    }

    return GradientContainer(
      child: Column(
        children: [
          // Mapa (ocupa el 55% de la pantalla)
          Expanded(
            flex: 55,
            child: MapaWidget(data: data),
          ),

          // Información debajo del mapa (45%)
          Expanded(
            flex: 45,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                // Resumen de la ruta
                ResumenRutaWidget(data: data),
                
                const SizedBox(height: 12),
                
                // Timeline de tramos (solo para itinerarios)
                if (data.esItinerario && data.itinerario != null && data.itinerario!.tramos != null)
                  TramosTimelineWidget(
                    tramos: data.itinerario!.tramos!,
                  ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de loading
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.blue3,
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando ruta...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Vista de error
  Widget _buildErrorView(String message) {
    return GradientContainer(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadRutaData,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue3,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =============================================
// Admin Map Widget
// Mapa con múltiples unidades para Admin
// =============================================

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';

class AdminMapWidget extends StatefulWidget {
  final List<UnidadTracking> unidades;
  final Function(int unidadId)? onUnitTapped;

  const AdminMapWidget({
    super.key,
    required this.unidades,
    this.onUnitTapped,
  });

  @override
  State<AdminMapWidget> createState() => AdminMapWidgetState();
}

class AdminMapWidgetState extends State<AdminMapWidget> 
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isMapCreated = false;
  
  // Ubicación inicial (Centro de Perú)
  static const LatLng _initialPosition = LatLng(-9.19, -75.0152);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _updateMarkers();
  }

  @override
  void didUpdateWidget(AdminMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Solo actualizar marcadores si cambiaron las unidades
    if (_hasUnitsChanged(oldWidget.unidades, widget.unidades)) {
      _updateMarkers();
    }
  }

  /// Verificar si las unidades cambiaron
  bool _hasUnitsChanged(List<UnidadTracking> oldUnits, List<UnidadTracking> newUnits) {
    if (oldUnits.length != newUnits.length) return true;
    
    for (int i = 0; i < oldUnits.length; i++) {
      final oldUnit = oldUnits[i];
      final newUnit = newUnits[i];
      
      if (oldUnit.unidadId != newUnit.unidadId ||
          oldUnit.ultimaUbicacion?.latitud != newUnit.ultimaUbicacion?.latitud ||
          oldUnit.ultimaUbicacion?.longitud != newUnit.ultimaUbicacion?.longitud ||
          oldUnit.estado != newUnit.estado) {
        return true;
      }
    }
    
    return false;
  }

  /// Actualizar marcadores sin recrear el mapa
  void _updateMarkers() {
    final Set<Marker> newMarkers = {};
    
    for (var unidad in widget.unidades) {
      if (unidad.ultimaUbicacion != null) {
        newMarkers.add(
          Marker(
            markerId: MarkerId('unit_${unidad.unidadId}'),
            position: LatLng(
              unidad.ultimaUbicacion!.latitud,
              unidad.ultimaUbicacion!.longitud,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              unidad.isActive 
                ? BitmapDescriptor.hueGreen 
                : BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(
              title: unidad.placa,
              snippet: unidad.isActive 
                ? '${unidad.ultimaUbicacion!.velocidad?.toStringAsFixed(0) ?? 0} km/h'
                : 'Inactiva',
            ),
            onTap: () => widget.onUnitTapped?.call(unidad.unidadId),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Requerido por AutomaticKeepAliveClientMixin

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _getMapCenter(),
          zoom: _calculateZoom(),
        ),
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          if (!_isMapCreated) {
            _mapController = controller;
            _isMapCreated = true;
            
            // Ajustar mapa inicial si hay unidades
            if (widget.unidades.isNotEmpty) {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _fitMapToMarkers();
                }
              });
            }
          }
        },
        mapType: MapType.normal,
      ),
    );
  }

  /// Calcular centro del mapa basado en las unidades
  LatLng _getMapCenter() {
    if (widget.unidades.isEmpty) return _initialPosition;

    final unidadesConUbicacion = widget.unidades
        .where((u) => u.ultimaUbicacion != null)
        .toList();

    if (unidadesConUbicacion.isEmpty) return _initialPosition;

    double sumLat = 0;
    double sumLng = 0;

    for (var unidad in unidadesConUbicacion) {
      sumLat += unidad.ultimaUbicacion!.latitud;
      sumLng += unidad.ultimaUbicacion!.longitud;
    }

    return LatLng(
      sumLat / unidadesConUbicacion.length,
      sumLng / unidadesConUbicacion.length,
    );
  }

  /// Calcular zoom apropiado
  double _calculateZoom() {
    if (widget.unidades.length <= 1) return 14;
    if (widget.unidades.length <= 5) return 12;
    return 10;
  }

  /// Método público para centrar mapa en una unidad
  void centerOnUnit(int unidadId) {
    final unidad = widget.unidades.firstWhere(
      (u) => u.unidadId == unidadId,
      orElse: () => widget.unidades.first,
    );

    if (unidad.ultimaUbicacion != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            unidad.ultimaUbicacion!.latitud,
            unidad.ultimaUbicacion!.longitud,
          ),
          16,
        ),
      );
    }
  }

  /// Ajustar mapa para mostrar todos los marcadores
  void _fitMapToMarkers() {
    if (_mapController == null) return;
    if (widget.unidades.isEmpty) return;

    final unidadesConUbicacion = widget.unidades
        .where((u) => u.ultimaUbicacion != null)
        .toList();

    if (unidadesConUbicacion.isEmpty) return;
    if (unidadesConUbicacion.length == 1) {
      centerOnUnit(unidadesConUbicacion.first.unidadId);
      return;
    }

    double minLat = unidadesConUbicacion.first.ultimaUbicacion!.latitud;
    double maxLat = minLat;
    double minLng = unidadesConUbicacion.first.ultimaUbicacion!.longitud;
    double maxLng = minLng;

    for (var unidad in unidadesConUbicacion) {
      final lat = unidad.ultimaUbicacion!.latitud;
      final lng = unidad.ultimaUbicacion!.longitud;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50, // padding
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
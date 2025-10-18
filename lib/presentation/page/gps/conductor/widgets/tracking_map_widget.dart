// =============================================
// Tracking Map Widget
// Mapa que muestra la ubicación del conductor
// =============================================

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class TrackingMapWidget extends StatefulWidget {
  final Position? currentPosition;
  final bool isTracking;
  final Function(GoogleMapController)? onMapCreated;

  const TrackingMapWidget({
    super.key,
    this.currentPosition,
    this.isTracking = false,
    this.onMapCreated,
  });

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _vehicleIcon;
  
  // Ubicación inicial (Perú - default)
  static const LatLng _initialPosition = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    _loadVehicleIcon();
  }

  /// Cargar icono personalizado de vehículo
  Future<void> _loadVehicleIcon() async {
    try {
      // Intentar cargar icono personalizado desde assets
      final icon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(40, 40)),
        'assets/icons/vehicle_marker.png',
      );
      
      if (mounted) {
        setState(() {
          _vehicleIcon = icon;
        });
      }
    } catch (e) {
      // Si no existe el asset, usar icono por defecto
      if (mounted) {
        setState(() {
          _vehicleIcon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.currentPosition;
    final hasPosition = position != null;

    // Crear marcador si hay posición
    final Set<Marker> markers = hasPosition
        ? {
            Marker(
              markerId: const MarkerId('current_location'),
              position: LatLng(position.latitude, position.longitude),
              // Usar icono de vehículo personalizado
              icon: _vehicleIcon ?? BitmapDescriptor.defaultMarkerWithHue(
                widget.isTracking
                    ? BitmapDescriptor.hueGreen
                    : BitmapDescriptor.hueRed,
              ),
              // Rotar el marcador según el rumbo (heading)
              rotation: position.heading,
              // Anclar el icono en el centro
              anchor: const Offset(0.5, 0.5),
              infoWindow: InfoWindow(
                title: '🚗 Mi Vehículo',
                snippet: widget.isTracking ? '✅ Tracking activo' : '⏸️ Detenido',
              ),
            ),
          }
        : {};

    // Círculo de precisión
    final Set<Circle> circles = hasPosition && position.accuracy > 0
        ? {
            Circle(
              circleId: const CircleId('accuracy'),
              center: LatLng(position.latitude, position.longitude),
              radius: position.accuracy,
              fillColor: Colors.blue.withValues(alpha: 0.2),
              strokeColor: Colors.blue.withValues(alpha: 0.5),
              strokeWidth: 1,
            ),
          }
        : {};

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: hasPosition
              ? LatLng(position.latitude, position.longitude)
              : _initialPosition,
          zoom: hasPosition ? 16 : 12,  // ! Aumentado de 16 a 18 para más zoom
        ),
        markers: markers,
        circles: circles,
        // ✅ Desactivar el pointer azul de "Mi ubicación"
        myLocationEnabled: false,  // Cambiado a false
        myLocationButtonEnabled: true,  // Mantener el botón para centrar
        compassEnabled: true,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          widget.onMapCreated?.call(controller);
        },
        mapType: MapType.normal,
      ),
    );
  }

  @override
  void didUpdateWidget(TrackingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar cámara si cambió la posición
    if (widget.currentPosition != null &&
        oldWidget.currentPosition != widget.currentPosition) {
      _updateCamera();
    }
  }

  /// Actualizar cámara para centrar en la ubicación actual
  void _updateCamera() {
    if (_mapController != null && widget.currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              widget.currentPosition!.latitude,
              widget.currentPosition!.longitude,
            ),
            zoom: 16,  // ! Mantener el zoom al actualizar
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
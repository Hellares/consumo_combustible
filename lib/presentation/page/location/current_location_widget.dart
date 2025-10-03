import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:flutter/material.dart';

class CurrentLocationWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const CurrentLocationWidget({super.key, this.onTap});

  @override
  State<CurrentLocationWidget> createState() => _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends State<CurrentLocationWidget> {
  SelectedLocation? _location;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final locationUseCases = locator<LocationUseCases>();
    final location = await locationUseCases.getSelectedLocation.run();
    
    if (mounted) {
      setState(() => _location = location);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_location == null) {
      return InkWell(
        onTap: widget.onTap ?? () => _navigateToSelection(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_location, size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 4),
              Text(
                'Seleccionar ubicación',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: widget.onTap ?? () => _navigateToSelection(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.blue.shade700),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _location!.grifo.nombre,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_location!.zona.nombre} • ${_location!.sede.nombre}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: Colors.blue.shade700),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToSelection(BuildContext context) async {
    final result = await Navigator.pushNamed(context, 'location-selection');
    
    if (result != null && mounted) {
      _loadLocation();
    }
  }
}
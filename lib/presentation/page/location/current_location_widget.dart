// import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_bloc.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_event.dart';
import 'package:consumo_combustible/presentation/page/location/bloc/location_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentLocationWidget extends StatefulWidget {
  final VoidCallback? onTap;

  const CurrentLocationWidget({super.key, this.onTap});

  @override
  State<CurrentLocationWidget> createState() => _CurrentLocationWidgetState();
}

class _CurrentLocationWidgetState extends State<CurrentLocationWidget> {
  @override
  void initState() {
    super.initState();
    // Cargar ubicación guardada al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(const LoadSavedLocation());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationBloc, LocationState>(
      builder: (context, state) {
        final location = state.savedLocation;

        if (location == null) {
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
                      location.grifo.nombre,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${location.zona.nombre} • ${location.sede.nombre}',
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
      },
    );
  }

  Future<void> _navigateToSelection(BuildContext context) async {
    final result = await Navigator.pushNamed(context, 'location-selection');
    
    // ✅ Verificar mounted y usar context de forma segura
    if (!mounted) return;
    
    // Recargar ubicación después de regresar
    context.read<LocationBloc>().add(const LoadSavedLocation());
    
    // Mostrar confirmación si se guardó exitosamente
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ubicación actualizada'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
// =============================================
// Units List Panel
// Panel lateral con lista de unidades
// =============================================

import 'package:flutter/material.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/presentation/page/gps/admin/widgets/unit_card.dart';

class UnitsListPanel extends StatelessWidget {
  final List<UnidadTracking> unidades;
  final int? selectedUnitId;
  final Function(int unidadId)? onUnitSelected;
  final VoidCallback? onRefresh;

  const UnitsListPanel({
    super.key,
    required this.unidades,
    this.selectedUnitId,
    this.onUnitSelected,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unidades de Transporte',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // const SizedBox(height: 2),
                    Text(
                      '${_getActiveCount()} activas de ${unidades.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                  tooltip: 'Actualizar',
                  iconSize: 18,
                ),
              ],
            ),
          ),

          // Lista de unidades
          Expanded(
            child: unidades.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: unidades.length,
                    itemBuilder: (context, index) {
                      final unidad = unidades[index];
                      return UnitCard(
                        unidad: unidad,
                        isSelected: unidad.unidadId == selectedUnitId,
                        onTap: () => onUnitSelected?.call(unidad.unidadId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay unidades con ubicación',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  int _getActiveCount() {
    return unidades.where((u) => u.isActive).length;
  }
}
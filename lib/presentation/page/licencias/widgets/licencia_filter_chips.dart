// lib/presentation/page/licencias/widgets/licencia_filter_chips.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class LicenciaFilterChips extends StatefulWidget {
  final Function(String) onFilterChanged;

  const LicenciaFilterChips({
    super.key,
    required this.onFilterChanged,
  });

  @override
  State<LicenciaFilterChips> createState() => _LicenciaFilterChipsState();
}

class _LicenciaFilterChipsState extends State<LicenciaFilterChips> {
  String _selectedFilter = 'TODAS';

  final List<Map<String, dynamic>> _filters = [
    {
      'label': 'Todas',
      'value': 'TODAS',
      'icon': Icons.list_alt,
    },
    {
      'label': 'Vigentes',
      'value': 'VIGENTES',
      'icon': Icons.check_circle_outline,
    },
    {
      'label': 'Próximas',
      'value': 'PROXIMAS',
      'icon': Icons.warning_amber_outlined,
    },
    {
      'label': 'Vencidas',
      'value': 'VENCIDAS',
      'icon': Icons.cancel_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        // ignore: unnecessary_underscores
        separatorBuilder: (_, __) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return Center(
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter['icon'] as IconData,
                    size: 14,
                    color: isSelected ? Colors.white : AppColors.blue3,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.blue3,
                      fontSize: 10
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter['value'] as String;
                });
                widget.onFilterChanged(_selectedFilter);
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.blue3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(
                  color: isSelected ? AppColors.blue3 : Colors.grey[300]!,
                  width: 1.5,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
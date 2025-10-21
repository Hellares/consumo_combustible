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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter['value'];

          return Align(
            alignment: Alignment.center,
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
                      fontSize: 9,
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
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: isSelected ? AppColors.blue3 : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -2, vertical: -4),
            ),
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/utils/enum_visuals.dart';
import 'package:tracking_requests/core/enums/request_status_enum.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_typography.dart';

class FilterBar extends StatelessWidget {
  final RequestStatusEnum? selected;
  final ValueChanged<RequestStatusEnum?> onChanged;

  const FilterBar({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = <(RequestStatusEnum?, String)>[
      (null, 'Todas'),
      ...RequestStatusEnum.values.map((s) => (s, s.label)),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (value, label) = options[i];
          return _Chip(
            label: label,
            isSelected: value == selected,
            onTap: () => onChanged(value),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: isSelected ? primary : AppColors.surface,
      borderRadius: AppRadius.pillRadius,
      child: InkWell(
        borderRadius: AppRadius.pillRadius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: AppRadius.pillRadius,
            border: isSelected
                ? null
                : Border.all(color: AppColors.border, width: 1),
          ),
          child: Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 13,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

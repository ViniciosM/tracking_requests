import 'package:flutter/material.dart';

import '../app_typography.dart';

class AppFab extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onPressed;

  const AppFab({super.key, this.icon = Icons.add, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glow = [
      BoxShadow(
        color: scheme.primary.withAlpha(40),
        blurRadius: 22,
        offset: const Offset(0, 8),
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(label == null ? 18 : 999),
        onTap: onPressed,
        child: Container(
          height: label == null ? 56 : 52,
          width: label == null ? 56 : null,
          padding: label == null
              ? null
              : const EdgeInsets.symmetric(horizontal: 22),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(label == null ? 18 : 999),
            boxShadow: glow,
          ),
          child: label == null
              ? Icon(icon, color: scheme.onPrimary, size: 26)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: scheme.onPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label!,
                      style: AppTypography.label.copyWith(
                        color: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

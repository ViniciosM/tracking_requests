import 'package:flutter/material.dart';
import 'package:tracking_requests/core/design_system/color_utils.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_typography.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final bg = !enabled
        ? AppColors.disabled
        : (_pressed ? scheme.primary.darken() : scheme.primary);
    final fg = enabled ? scheme.onPrimary : AppColors.textTertiary;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 48,
        width: widget.fullWidth ? double.infinity : null,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.buttonRadius,
          boxShadow: enabled && !_pressed
              ? [
                  BoxShadow(
                    color: scheme.primary.withAlpha(40),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(scheme.onPrimary),
                ),
              )
            : Row(
                mainAxisSize: widget.fullWidth
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: fg),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.label.copyWith(color: fg),
                  ),
                ],
              ),
      ),
    );
  }
}

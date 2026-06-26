import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_typography.dart';

class AppTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscure;
  final bool enabled;
  final int maxLines;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.obscure = false,
    this.enabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focusNode = FocusNode();
  late bool _obscured = widget.obscure;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _focused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final hasError = widget.errorText != null;
    final borderColor = hasError
        ? AppColors.error
        : (_focused ? primary : AppColors.border);
    final borderWidth = (hasError || _focused) ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTypography.label.copyWith(
              fontSize: 13,
              color: _focused && !hasError ? primary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.background,
            borderRadius: AppRadius.inputRadius,
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: primary.withAlpha(38),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: _obscured,
            maxLines: widget.obscure ? 1 : widget.maxLines,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            style: AppTypography.bodyLarge,
            cursorColor: primary,
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: AppTypography.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: InputBorder.none,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: AppColors.textTertiary,
                      size: 20,
                    )
                  : null,
              suffixIcon: widget.obscure
                  ? IconButton(
                      icon: Icon(
                        _obscured ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscured = !_obscured),
                    )
                  : null,
            ),
          ),
        ),
        if (hasError || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText ?? widget.helperText!,
            style: AppTypography.caption.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

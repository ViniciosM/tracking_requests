import 'package:flutter/material.dart';

import '../app_typography.dart';

class AiSuggestButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AiSuggestButton({super.key, this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: primary.withAlpha(25),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: isLoading ? null : onPressed,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                )
              else
                Icon(Icons.auto_awesome, size: 16, color: primary),
              const SizedBox(width: 8),
              Text(
                isLoading ? 'Gerando sugestão…' : 'Sugerir com IA',
                style: AppTypography.label.copyWith(
                  color: primary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

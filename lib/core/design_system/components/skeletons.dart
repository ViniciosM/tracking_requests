import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

const Color _block = Color(0xFFECEAF1);
const Color _blockSoft = Color(0xFFF0EFF3);

class RequestCardSkeleton extends StatefulWidget {
  const RequestCardSkeleton({super.key});

  @override
  State<RequestCardSkeleton> createState() => _RequestCardSkeletonState();
}

class _RequestCardSkeletonState extends State<RequestCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.55, end: 1.0).animate(_c),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.cardRadius,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(40, 40, radius: 11),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(double.infinity, 14, color: _block),
                  const SizedBox(height: 10),
                  _box(140, 11, color: _blockSoft),
                  const SizedBox(height: 14),
                  _box(70, 22, radius: 999),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 6, Color color = _block}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class RequestListSkeleton extends StatelessWidget {
  final int count;
  const RequestListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screen),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const RequestCardSkeleton(),
    );
  }
}

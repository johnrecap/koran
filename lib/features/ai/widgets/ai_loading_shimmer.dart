import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class AiLoadingShimmer extends StatefulWidget {
  const AiLoadingShimmer({
    super.key,
    required this.label,
  });

  final String label;

  @override
  State<AiLoadingShimmer> createState() => _AiLoadingShimmerState();
}

class _AiLoadingShimmerState extends State<AiLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacity = Tween<double>(
    begin: 0.35,
    end: 0.85,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.textDark.withValues(alpha: 0.16)
        : AppColors.camel.withValues(alpha: 0.18);

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        key: const Key('ai-loading-shimmer'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.72)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: 14),
            _ShimmerLine(
              key: const Key('ai-loading-shimmer-line-1'),
              widthFactor: 1,
              color: baseColor,
            ),
            const SizedBox(height: 10),
            _ShimmerLine(
              key: const Key('ai-loading-shimmer-line-2'),
              widthFactor: 0.86,
              color: baseColor,
            ),
            const SizedBox(height: 10),
            _ShimmerLine(
              key: const Key('ai-loading-shimmer-line-3'),
              widthFactor: 0.62,
              color: baseColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({
    super.key,
    required this.widthFactor,
    required this.color,
  });

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

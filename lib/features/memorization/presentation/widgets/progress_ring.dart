import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

/// Circular progress ring showing memorization percentage.
/// Gold stroke on light background with percentage text in center.
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String label;
  final double size;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.label,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressRingPainter(
          progress: progress,
          isDark: isDark,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final shortestSide = min(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            final percentageFontSize =
                (shortestSide * 0.32).clamp(18.0, 32.0).toDouble();
            final labelFontSize =
                (shortestSide * 0.12).clamp(8.0, 12.0).toDouble();
            final spacing =
                (shortestSide * 0.04).clamp(2.0, 4.0).toDouble();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: shortestSide * 0.78,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: percentageFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                        height: 1.0,
                      ),
                      maxLines: 1,
                    ),
                    SizedBox(height: spacing),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: AppColors.textMuted,
                        fontFamily: 'Amiri',
                        height: 1.1,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _ProgressRingPainter({
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 8.0;

    // Background ring
    final bgPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      progress != oldDelegate.progress || isDark != oldDelegate.isDark;
}

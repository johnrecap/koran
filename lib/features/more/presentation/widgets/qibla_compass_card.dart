import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/more/domain/qibla_compass_models.dart';

class QiblaCompassCard extends StatelessWidget {
  const QiblaCompassCard({
    super.key,
    required this.snapshot,
    required this.title,
    required this.distanceLabel,
    required this.distanceValue,
    required this.bearingLabel,
    required this.headingLabel,
    required this.statusLabel,
    required this.guidanceLabel,
    required this.showGuidance,
  });

  final QiblaCompassSnapshot snapshot;
  final String title;
  final String distanceLabel;
  final String distanceValue;
  final String bearingLabel;
  final String headingLabel;
  final String statusLabel;
  final String guidanceLabel;
  final bool showGuidance;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDarkNav : Colors.white;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final mutedColor = isDark
        ? AppColors.textDark.withValues(alpha: 0.68)
        : AppColors.textMuted;
    final statusColor = snapshot.isFacingQibla
        ? AppColors.success
        : snapshot.calibrationState == QiblaCalibrationState.ready
            ? AppColors.gold
            : AppColors.warmBrown;

    return Container(
      key: const Key('qibla-compass-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.16 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            snapshot.locationLabel,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              color: mutedColor,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                label: distanceLabel,
                value: distanceValue,
              ),
              _InfoChip(
                label: bearingLabel,
                value: '${snapshot.qiblaBearingDegrees.round()}°',
              ),
              _InfoChip(
                label: headingLabel,
                value: snapshot.headingDegrees == null
                    ? '--'
                    : '${snapshot.headingDegrees!.round()}°',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(250),
                    painter: _CompassRingPainter(
                      borderColor: AppColors.gold.withValues(alpha: 0.28),
                      tickColor: AppColors.gold.withValues(alpha: 0.40),
                      fillColor: isDark
                          ? AppColors.surfaceDark.withValues(alpha: 0.65)
                          : AppColors.camel.withValues(alpha: 0.06),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const Positioned(top: 26, child: _CompassLabel(label: 'N')),
                  const Positioned(right: 24, child: _CompassLabel(label: 'E')),
                  const Positioned(
                      bottom: 26, child: _CompassLabel(label: 'S')),
                  const Positioned(left: 24, child: _CompassLabel(label: 'W')),
                  Transform.rotate(
                    angle: snapshot.relativeNeedleDegrees * math.pi / 180,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation_rounded,
                          size: 86,
                          color: statusColor,
                        ),
                        Text(
                          'Q',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cardColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              statusLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          if (showGuidance) ...[
            const SizedBox(height: 14),
            Container(
              key: const Key('qibla-guidance-state'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.camel.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                guidanceLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 16,
                  color: textColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.75)
            : AppColors.camel.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: isDark
                  ? AppColors.textDark.withValues(alpha: 0.72)
                  : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassLabel extends StatelessWidget {
  const _CompassLabel({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.textDark : AppColors.textLight,
      ),
    );
  }
}

class _CompassRingPainter extends CustomPainter {
  const _CompassRingPainter({
    required this.borderColor,
    required this.tickColor,
    required this.fillColor,
  });

  final Color borderColor;
  final Color tickColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final fillPaint = Paint()..color = fillColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius - 8, fillPaint);
    canvas.drawCircle(center, radius - 8, borderPaint);

    for (var index = 0; index < 36; index += 1) {
      final angle = (index * 10) * math.pi / 180;
      final isMajor = index % 3 == 0;
      final outer = Offset(
        center.dx + (radius - 18) * math.cos(angle - math.pi / 2),
        center.dy + (radius - 18) * math.sin(angle - math.pi / 2),
      );
      final inner = Offset(
        center.dx +
            (radius - (isMajor ? 34 : 28)) * math.cos(angle - math.pi / 2),
        center.dy +
            (radius - (isMajor ? 34 : 28)) * math.sin(angle - math.pi / 2),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CompassRingPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.tickColor != tickColor ||
        oldDelegate.fillColor != fillColor;
  }
}

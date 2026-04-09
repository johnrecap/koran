import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';

class HomeToolsIconGrid extends StatelessWidget {
  const HomeToolsIconGrid({
    super.key,
    required this.prayerTimesLabel,
    required this.qiblaLabel,
    required this.azkarLabel,
    required this.analyticsLabel,
    required this.settingsLabel,
    this.onQiblaTap,
    this.onAzkarTap,
    this.onAnalyticsTap,
    this.onSettingsTap,
  });

  final String prayerTimesLabel;
  final String qiblaLabel;
  final String azkarLabel;
  final String analyticsLabel;
  final String settingsLabel;
  final VoidCallback? onQiblaTap;
  final VoidCallback? onAzkarTap;
  final VoidCallback? onAnalyticsTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final items =
        <({Key key, IconData icon, String label, VoidCallback? onTap})>[
      (
        key: const Key('home-tools-prayer-times-tool'),
        icon: Icons.access_time_filled_rounded,
        label: prayerTimesLabel,
        onTap: null,
      ),
      (
        key: const Key('home-tools-qibla-tool'),
        icon: Icons.explore_rounded,
        label: qiblaLabel,
        onTap: onQiblaTap,
      ),
      (
        key: const Key('home-tools-azkar-tool'),
        icon: Icons.auto_stories_rounded,
        label: azkarLabel,
        onTap: onAzkarTap,
      ),
      (
        key: const Key('home-tools-analytics-tool'),
        icon: Icons.insights_rounded,
        label: analyticsLabel,
        onTap: onAnalyticsTap,
      ),
      (
        key: const Key('home-tools-settings-tool'),
        icon: Icons.tune_rounded,
        label: settingsLabel,
        onTap: onSettingsTap,
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        return _ToolBubble(
          key: item.key,
          icon: item.icon,
          label: item.label,
          onTap: item.onTap,
        );
      }).toList(growable: false),
    );
  }
}

class _ToolBubble extends StatelessWidget {
  const _ToolBubble({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return SizedBox(
      width: 78,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.surfaceDarkNav
                    : AppColors.camel.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.22),
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.gold,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 13,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

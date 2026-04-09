import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_config.dart';
import 'package:quran_kareem/features/tafsir/domain/insight_section_models.dart';

class InsightSectionShell extends StatefulWidget {
  const InsightSectionShell({
    super.key,
    required this.config,
    required this.data,
    required this.child,
  });

  final InsightSectionConfig config;
  final InsightSectionData data;
  final Widget child;

  @override
  State<InsightSectionShell> createState() => _InsightSectionShellState();
}

class _InsightSectionShellState extends State<InsightSectionShell> {
  bool _isExpanded = true;
  Object? _lastLoggedError;

  @override
  void initState() {
    super.initState();
    _logErrorIfNeeded();
  }

  @override
  void didUpdateWidget(covariant InsightSectionShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _logErrorIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data is InsightSectionUnavailable) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = _resolveSectionTitle(context.l10n, widget.config.titleKey);
    final titleColor = isDark ? AppColors.textDark : AppColors.textLight;
    final surfaceColor = isDark
        ? AppColors.surfaceDarkNav.withValues(alpha: 0.86)
        : Colors.white.withValues(alpha: 0.94);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      widget.config.icon,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _toggleExpanded,
                  icon: Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                  label: Text(
                    _isExpanded
                        ? context.l10n.insightSectionCollapse
                        : context.l10n.insightSectionExpand,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _isExpanded ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: switch (widget.data) {
                      InsightSectionLoaded() => widget.child,
                      InsightSectionError() => _InsightSectionErrorBody(
                          message: context.l10n.errorLoadingData,
                        ),
                      _ => const SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _logErrorIfNeeded() {
    final data = widget.data;
    if (data case InsightSectionError(:final error)) {
      if (!identical(error, _lastLoggedError)) {
        _lastLoggedError = error;
        AppLogger.error(
          'InsightSectionShell.${widget.config.type.name}',
          error,
        );
      }
    }
  }
}

class _InsightSectionErrorBody extends StatelessWidget {
  const _InsightSectionErrorBody({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colorScheme.error,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _resolveSectionTitle(AppLocalizations l10n, String titleKey) {
  switch (titleKey) {
    case InsightSectionTitleKeys.tafsir:
      return l10n.insightSectionTafsir;
    case InsightSectionTitleKeys.wordMeaning:
      return l10n.insightSectionWordMeaning;
    case InsightSectionTitleKeys.asbaab:
      return l10n.insightSectionAsbaab;
    case InsightSectionTitleKeys.related:
      return l10n.insightSectionRelated;
    default:
      return titleKey;
  }
}

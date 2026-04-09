import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/onboarding/providers/onboarding_providers.dart';

class MushafSetupScreen extends ConsumerStatefulWidget {
  const MushafSetupScreen({super.key});

  @override
  ConsumerState<MushafSetupScreen> createState() => _MushafSetupScreenState();
}

class _MushafSetupScreenState extends ConsumerState<MushafSetupScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(mushafPreparationControllerProvider.notifier).startIfNeeded(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MushafPreparationState>(
      mushafPreparationControllerProvider,
      (previous, next) {
        if (next.isCompleted && mounted) {
          context.go('/library');
        }
      },
    );

    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.textLight;
    final subtitleColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.92);
    final state = ref.watch(mushafPreparationControllerProvider);
    final progress = state.progress.clamp(0.0, 1.0);
    final isBusy =
        state.status == MushafPreparationStatus.idle || state.isPreparing;

    return PopScope(
      canPop: false,
      child: Scaffold(
        key: const Key('mushaf-setup-bridge'),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primaryDark,
                Color(0xFF0F2218),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.goldReader.withValues(alpha: 0.25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 32,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  AppColors.goldReader.withValues(alpha: 0.14),
                            ),
                            child: Icon(
                              state.isFailed
                                  ? Icons.refresh_rounded
                                  : Icons.downloading_rounded,
                              color: AppColors.goldReader,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.mushafSetupBridgeTitle,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.mushafSetupBridgeDescription,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: subtitleColor,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (isBusy) ...[
                            Text(
                              l10n.mushafSetupInProgress,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                minHeight: 10,
                                value: progress == 0 ? 0.02 : progress,
                                backgroundColor: AppColors.goldReader
                                    .withValues(alpha: 0.18),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.goldReader,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                          if (state.isFailed) ...[
                            Text(
                              l10n.mushafSetupError,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => ref
                                  .read(
                                    mushafPreparationControllerProvider.notifier,
                                  )
                                  .retry(),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.goldReader,
                                foregroundColor: AppColors.primaryDark,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: Text(l10n.mushafSetupRetry),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

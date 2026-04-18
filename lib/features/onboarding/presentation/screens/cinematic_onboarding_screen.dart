import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/features/onboarding/domain/cinematic_onboarding_scene.dart';
import 'package:quran_kareem/features/onboarding/domain/startup_route_policy.dart';
import 'package:quran_kareem/features/onboarding/presentation/widgets/cinematic_scene_video.dart';
import 'package:quran_kareem/features/onboarding/providers/onboarding_providers.dart';

typedef OnboardingSceneVisualBuilder = Widget Function(
  BuildContext context,
  CinematicOnboardingScene scene,
);

class CinematicOnboardingScreen extends ConsumerStatefulWidget {
  const CinematicOnboardingScreen({
    this.sceneVisualBuilder,
    super.key,
  });

  final OnboardingSceneVisualBuilder? sceneVisualBuilder;

  @override
  ConsumerState<CinematicOnboardingScreen> createState() =>
      _CinematicOnboardingScreenState();
}

class _CinematicOnboardingScreenState
    extends ConsumerState<CinematicOnboardingScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    Future<void>.microtask(
      () => ref.read(mushafPreparationControllerProvider.notifier).startIfNeeded(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await UserPreferences.setOnboardingComplete(true);
    final setupState = ref.read(mushafPreparationControllerProvider);
    final target = StartupRoutePolicy.resolveAfterOnboarding(
      isPermissionsFlowComplete: false,
      isMushafSetupComplete: setupState.isCompleted,
    );
    if (mounted) {
      context.go(target.path);
    }
  }

  void _goToNext(List<CinematicOnboardingScene> scenes) {
    if (_currentIndex >= scenes.length - 1) {
      _finishOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scenes = _buildScenes(l10n);
    final preparationState = ref.watch(mushafPreparationControllerProvider);
    final progressPercent = (preparationState.progress * 100).round();
    final isLastScene = _currentIndex == scenes.length - 1;

    return Scaffold(
      key: const Key('onboarding-screen'),
      backgroundColor: AppColors.surfaceDark,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceDark,
              AppColors.surfaceDark.withValues(alpha: 0.96),
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              left: -60,
              child: _GlowOrb(
                color: AppColors.gold.withValues(alpha: 0.12),
                size: 220,
              ),
            ),
            Positioned(
              right: -90,
              bottom: 180,
              child: _GlowOrb(
                color: AppColors.camel.withValues(alpha: 0.1),
                size: 260,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _TopBadge(label: l10n.onboardingEyebrow),
                        const Spacer(),
                        TextButton(
                          key: const Key('onboarding-skip-button'),
                          onPressed: _finishOnboarding,
                          child: Text(l10n.onboardingSkip),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: PageView.builder(
                        key: const Key('onboarding-page-view'),
                        controller: _pageController,
                        itemCount: scenes.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final scene = scenes[index];
                          return LayoutBuilder(
                            builder: (context, constraints) {
                              final mediaHeight = constraints.maxHeight * 0.54;
                              return SingleChildScrollView(
                                physics: const ClampingScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: mediaHeight.clamp(260, 420),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                          ),
                                          child: _SceneFrame(
                                            child: widget.sceneVisualBuilder?.call(
                                                  context,
                                                  scene,
                                                ) ??
                                                CinematicSceneVideo(
                                                  assetPath: scene.assetPath,
                                                  fallbackIcon:
                                                      _sceneIcons[index],
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 280),
                                        child: Column(
                                          key: ValueKey(scene.assetPath),
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              scene.title,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontFamily: 'Amiri',
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              scene.description,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                height: 1.75,
                                                color: AppColors.textDark
                                                    .withValues(alpha: 0.76),
                                              ),
                                            ),
                                            const SizedBox(height: 22),
                                            _OnboardingIndicator(
                                              currentIndex: _currentIndex,
                                              itemCount: scenes.length,
                                            ),
                                            const SizedBox(height: 18),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withValues(alpha: 0.06),
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                                border: Border.all(
                                                  color: AppColors.gold
                                                      .withValues(alpha: 0.16),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    preparationState.isCompleted
                                                        ? Icons
                                                            .check_circle_rounded
                                                        : Icons
                                                            .downloading_rounded,
                                                    color: AppColors.goldReader,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      preparationState
                                                              .isCompleted
                                                          ? l10n
                                                              .onboardingBackgroundReady
                                                          : l10n
                                                              .onboardingBackgroundLoading,
                                                      style: TextStyle(
                                                        color: AppColors
                                                            .textDark
                                                            .withValues(
                                                          alpha: 0.84,
                                                        ),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (!preparationState
                                                      .isCompleted)
                                                    Text(
                                                      '$progressPercent%',
                                                      style: const TextStyle(
                                                        color: AppColors
                                                            .goldReader,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            key: Key(
                              isLastScene
                                  ? 'onboarding-start-button'
                                  : 'onboarding-next-button',
                            ),
                            onPressed: () => _goToNext(scenes),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.goldReader,
                              foregroundColor: AppColors.surfaceDark,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(
                              isLastScene
                                  ? l10n.onboardingStart
                                  : l10n.onboardingNext,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_currentIndex + 1}/${scenes.length}',
                      style: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CinematicOnboardingScene> _buildScenes(AppLocalizations l10n) {
    return [
      CinematicOnboardingScene(
        assetPath: 'assets/videos/1.mp4',
        title: l10n.onboardingReadTitle,
        description: l10n.onboardingReadDescription,
      ),
      CinematicOnboardingScene(
        assetPath: 'assets/videos/2.mp4',
        title: l10n.onboardingListenTitle,
        description: l10n.onboardingListenDescription,
      ),
      CinematicOnboardingScene(
        assetPath: 'assets/videos/3.mp4',
        title: l10n.onboardingSaveTitle,
        description: l10n.onboardingSaveDescription,
      ),
      CinematicOnboardingScene(
        assetPath: 'assets/videos/4.mp4',
        title: l10n.onboardingDailyTitle,
        description: l10n.onboardingDailyDescription,
      ),
      CinematicOnboardingScene(
        assetPath: 'assets/videos/5.mp4',
        title: l10n.onboardingBeginTitle,
        description: l10n.onboardingBeginDescription,
      ),
    ];
  }
}

const List<IconData> _sceneIcons = [
  Icons.auto_stories_rounded,
  Icons.headphones_rounded,
  Icons.bookmark_added_rounded,
  Icons.explore_rounded,
  Icons.arrow_forward_rounded,
];

class _SceneFrame extends StatelessWidget {
  const _SceneFrame({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 38,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.camel.withValues(alpha: 0.18),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator({
    required this.currentIndex,
    required this.itemCount,
  });

  final int currentIndex;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.goldReader
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

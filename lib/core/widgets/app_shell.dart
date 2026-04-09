import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/features/audio/presentation/widgets/audio_mini_player.dart';
import 'package:quran_kareem/features/audio/providers/audio_providers.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    '/reader',
    '/audio',
    '/library',
    '/memorization',
    '/more',
  ];

  int _currentIndex(String location) {
    if (location.startsWith('/analytics')) {
      return 3;
    }

    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goldColor = isDark ? AppColors.goldGeneral : AppColors.goldReader;
    final sessionActivityAsync = ref.watch(audioHubSessionActivityProvider);
    final hasActiveAudioSession = sessionActivityAsync.value ??
        ref.watch(audioHubPlaybackServiceProvider).hasActiveSession;
    final hideBottomNavigation =
        ReaderShellChromePolicy.shouldHideBottomNavigation(
      location: location,
      isFullscreen: ref.watch(readerFullscreenModeProvider),
    );
    final showMiniPlayer = !hideBottomNavigation &&
        !location.startsWith('/audio') &&
        hasActiveAudioSession;

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: hideBottomNavigation
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showMiniPlayer)
                  _ShellMiniPlayer(
                    onOpen: () => context.go('/audio'),
                  ),
                RepaintBoundary(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceDarkNav.withValues(alpha: 0.94)
                          : Colors.white.withValues(alpha: 0.94),
                      border: Border(
                        top: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _NavItem(
                              icon: Icons.menu_book_rounded,
                              label: l10n.navReader,
                              isActive: currentIndex == 0,
                              goldColor: goldColor,
                              onTap: () {
                                ref
                                        .read(readerSessionIntentProvider
                                            .notifier)
                                        .state =
                                    const ReaderSessionIntent.general();
                                context.go(_tabs[0]);
                              },
                            ),
                            _NavItem(
                              icon: Icons.headphones_rounded,
                              label: l10n.navAudio,
                              isActive: currentIndex == 1,
                              goldColor: goldColor,
                              onTap: () => context.go(_tabs[1]),
                            ),
                            _NavItem(
                              icon: Icons.collections_bookmark_rounded,
                              label: l10n.navLibrary,
                              isActive: currentIndex == 2,
                              goldColor: goldColor,
                              onTap: () => context.go(_tabs[2]),
                            ),
                            _NavItem(
                              icon: Icons.psychology_rounded,
                              label: l10n.navMemorization,
                              isActive: currentIndex == 3,
                              goldColor: goldColor,
                              onTap: () => context.go(_tabs[3]),
                            ),
                            _NavItem(
                              icon: Icons.more_horiz_rounded,
                              label: l10n.navMore,
                              isActive: currentIndex == 4,
                              goldColor: goldColor,
                              onTap: () => context.go(_tabs[4]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ShellMiniPlayer extends ConsumerWidget {
  const _ShellMiniPlayer({
    required this.onOpen,
  });

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackAsync = ref.watch(audioHubControllerProvider);

    return playbackAsync.maybeWhen(
      data: (snapshot) {
        if (!snapshot.hasActiveSession) {
          return const SizedBox.shrink();
        }

        return AudioMiniPlayer(
          snapshot: snapshot,
          onOpen: onOpen,
          onTogglePlayPause: () async {
            await ref
                .read(audioHubControllerProvider.notifier)
                .togglePlayPause();
          },
          onStop: () async {
            await ref.read(audioHubControllerProvider.notifier).stop();
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.goldColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final Color goldColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: goldColor.withValues(alpha: 0.12),
      highlightColor: goldColor.withValues(alpha: 0.08),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? goldColor : Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? goldColor : Colors.grey,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 5 : 0,
              height: isActive ? 5 : 0,
              decoration: BoxDecoration(
                color: goldColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/audio/presentation/screens/audio_hub_screen.dart';
import '../../features/audio/presentation/screens/audio_download_manager_screen.dart';
import '../../features/audio/presentation/screens/audio_reciter_downloads_screen.dart';
import '../../features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/memorization/presentation/screens/memorization_screen.dart';
import '../../features/memorization/presentation/screens/achievements_dashboard_screen.dart';
import '../../features/memorization/presentation/screens/khatma_planner_screen.dart';
import '../../features/memorization/presentation/screens/review_queue_screen.dart';
import '../../features/memorization/presentation/screens/review_session_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/more/presentation/screens/adhkar_categories_screen.dart';
import '../../features/more/presentation/screens/adhkar_category_detail_screen.dart';
import '../../features/more/presentation/screens/prayer_times_details_screen.dart';
import '../../features/more/presentation/screens/qibla_compass_screen.dart';
import '../../features/more/domain/prayer_time_models.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/onboarding/presentation/screens/cinematic_onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/mushaf_setup_screen.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_history_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_hub_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_result_screen.dart';
import '../../features/quizzes/presentation/screens/quiz_session_screen.dart';
import '../../features/quizzes/providers/quiz_providers.dart';
import '../../features/reader/presentation/screens/reader_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/stories/presentation/stories_hub_screen.dart';
import '../../features/stories/presentation/story_reader_screen.dart';
import '../../features/tafsir/presentation/screens/tafsir_browser_screen.dart';
import 'app_transition_page.dart';
import '../widgets/app_shell.dart';

GoRouter createAppRouter({
  String initialLocation = '/splash',
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/setup-mushaf',
        builder: (context, state) => const MushafSetupScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const CinematicOnboardingScreen(),
      ),
      GoRoute(
        path: '/tafsir/:surah/:ayah',
        pageBuilder: (context, state) => AppTransitionPage<void>(
          key: state.pageKey,
          child: TafsirBrowserScreen(
            surahNumber: int.tryParse(state.pathParameters['surah'] ?? '') ?? 0,
            ayahNumber: int.tryParse(state.pathParameters['ayah'] ?? '') ?? 0,
          ),
        ),
      ),
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/reader',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReaderScreen(),
            ),
          ),
          GoRoute(
            path: '/audio',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AudioHubScreen(),
            ),
          ),
          GoRoute(
            path: '/audio/downloads',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const AudioDownloadManagerScreen(),
            ),
          ),
          GoRoute(
            path: '/audio/downloads/:reciterIndex',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: AudioReciterDownloadsScreen(
                reciterIndex:
                    int.tryParse(state.pathParameters['reciterIndex'] ?? '') ??
                        0,
              ),
            ),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AnalyticsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryScreen(),
            ),
          ),
          GoRoute(
            path: '/library/stories',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const StoriesHubScreen(),
            ),
          ),
          GoRoute(
            path: '/library/stories/:storyId',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: StoryReaderScreen(
                storyId: state.pathParameters['storyId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/memorization',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MemorizationScreen(),
            ),
          ),
          GoRoute(
            path: '/memorization/quiz',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: QuizHubScreen(
                onHistoryPressed: () {
                  context.push('/memorization/quiz/history');
                },
                onBeginQuiz: (context, config) async {
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  await container
                      .read(quizSessionProvider.notifier)
                      .startSession(config);

                  if (!context.mounted) {
                    return;
                  }

                  context.push('/memorization/quiz/session');
                },
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/quiz/session',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: QuizSessionScreen(
                onSessionComplete: (context, _) async {
                  if (!context.mounted) {
                    return;
                  }

                  context.pushReplacement('/memorization/quiz/result');
                },
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/quiz/result',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: QuizResultScreen(
                onTryAgain: (context, config) async {
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );
                  await container
                      .read(quizSessionProvider.notifier)
                      .startSession(config);

                  if (!context.mounted) {
                    return;
                  }

                  context.pushReplacement('/memorization/quiz/session');
                },
                onBackToHub: () {
                  context.go('/memorization/quiz');
                },
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/quiz/history',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const QuizHistoryScreen(),
            ),
          ),
          GoRoute(
            path: '/memorization/achievements',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const AchievementsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/memorization/reviews',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const ReviewQueueScreen(),
            ),
          ),
          GoRoute(
            path: '/memorization/reviews/:reviewId',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: ReviewSessionScreen(
                reviewId: state.pathParameters['reviewId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/memorization/khatma/:khatmaId',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: KhatmaPlannerScreen(
                khatmaId: state.pathParameters['khatmaId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/more',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
          GoRoute(
            path: '/more/adhkar',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const AdhkarCategoriesScreen(),
            ),
          ),
          GoRoute(
            path: '/more/adhkar/:categoryId',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: AdhkarCategoryDetailScreen(
                categoryId: state.pathParameters['categoryId']!,
              ),
            ),
          ),
          GoRoute(
            path: '/more/prayer-times',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: PrayerTimesDetailsScreen(
                initialSnapshot: state.extra is HomePrayerSnapshot
                    ? state.extra as HomePrayerSnapshot
                    : null,
              ),
            ),
          ),
          GoRoute(
            path: '/more/qibla',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const QiblaCompassScreen(),
            ),
          ),
          GoRoute(
            path: '/more/settings',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
          GoRoute(
            path: '/more/settings/notifications',
            pageBuilder: (context, state) => AppTransitionPage<void>(
              key: state.pageKey,
              child: const NotificationSettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}

final GoRouter appRouter = createAppRouter();

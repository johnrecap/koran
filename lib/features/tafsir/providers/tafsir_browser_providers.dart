import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';
import 'package:quran_kareem/features/tafsir/data/tafsir_browser_repository.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';
import 'package:quran_library/quran_library.dart';

class TafsirBrowserRouteArgs {
  const TafsirBrowserRouteArgs({
    required this.surahNumber,
    required this.ayahNumber,
  });

  final int surahNumber;
  final int ayahNumber;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TafsirBrowserRouteArgs &&
            other.surahNumber == surahNumber &&
            other.ayahNumber == ayahNumber);
  }

  @override
  int get hashCode => Object.hash(surahNumber, ayahNumber);
}

final tafsirBrowserAyahLookupProvider = Provider<TafsirBrowserAyahLookup>(
  (ref) => const QuranDatabaseTafsirBrowserAyahLookup(),
);

final tafsirBrowserCanonicalSurahsProvider = Provider<Iterable<SurahModel>>(
  (ref) => QuranCtrl.instance.surahs,
);

final tafsirBrowserRepositoryProvider = Provider<TafsirBrowserRepository>(
  (ref) => PackageTafsirBrowserRepository(),
);

final tafsirBrowserTargetProvider =
    FutureProvider.family<ReaderAyahInsightsTarget?, TafsirBrowserRouteArgs>(
  (ref, args) async {
    final ayah = await ref.watch(tafsirBrowserAyahLookupProvider).findAyah(
          surahNumber: args.surahNumber,
          ayahNumber: args.ayahNumber,
        );
    if (ayah == null) {
      return null;
    }

    return ReaderAyahInsightsPolicy.resolve(
      ayah: ayah,
      canonicalSurahs: ref.watch(tafsirBrowserCanonicalSurahsProvider),
    );
  },
);

final tafsirBrowserSourceOptionsProvider =
    FutureProvider<List<TafsirBrowserSourceOption>>((ref) async {
  return ref.watch(tafsirBrowserRepositoryProvider).fetchSourceOptions();
});

final tafsirBrowserContentProvider =
    FutureProvider.family<TafsirBrowserContentState, ReaderAyahInsightsTarget>(
  (ref, target) async {
    return ref.watch(tafsirBrowserRepositoryProvider).fetchContent(
          target: target,
        );
  },
);

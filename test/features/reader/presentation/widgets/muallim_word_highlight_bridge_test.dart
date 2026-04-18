import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/muallim_word_highlight_bridge.dart';
import 'package:quran_kareem/features/reader/providers/muallim_providers.dart';
import 'package:quran_library/quran_library.dart';

final _testMuallimHighlightProvider = StateProvider<MuallimWordHighlight>(
  (ref) => const MuallimWordHighlight.none(),
);

void main() {
  testWidgets('maps Muallim highlight into the selectedWordRef pipeline',
      (tester) async {
    final target = _FakeSelectionTarget();
    final container = await _pumpBridge(
      tester,
      selectionTarget: target,
      lookupAyahByUq: (_) => _ayah(
        ayahUQNumber: 7,
        surahNumber: 3,
        ayahNumber: 4,
      ),
    );

    container.read(_testMuallimHighlightProvider.notifier).state =
        const MuallimWordHighlight(
      ayahUQNumber: 7,
      wordIndex: 2,
    );
    await tester.pump();

    expect(
      target.selectedWordRef,
      const WordRef(
        surahNumber: 3,
        ayahNumber: 4,
        wordNumber: 3,
      ),
    );
    expect(target.setCallCount, 1);
  });

  testWidgets(
      'clears the bridge-owned selection when timing becomes unavailable',
      (tester) async {
    final target = _FakeSelectionTarget();
    final container = await _pumpBridge(
      tester,
      selectionTarget: target,
      lookupAyahByUq: (_) => _ayah(),
    );

    container.read(_testMuallimHighlightProvider.notifier).state =
        const MuallimWordHighlight(
      ayahUQNumber: 7,
      wordIndex: 1,
    );
    await tester.pump();

    container.read(_testMuallimHighlightProvider.notifier).state =
        const MuallimWordHighlight(
      ayahUQNumber: 7,
      wordIndex: null,
    );
    await tester.pump();

    expect(target.selectedWordRef, isNull);
    expect(target.clearCallCount, 1);
  });

  testWidgets('dispose clears only the selection owned by the bridge',
      (tester) async {
    final target = _FakeSelectionTarget();
    final container = await _pumpBridge(
      tester,
      selectionTarget: target,
      lookupAyahByUq: (_) => _ayah(),
    );

    container.read(_testMuallimHighlightProvider.notifier).state =
        const MuallimWordHighlight(
      ayahUQNumber: 7,
      wordIndex: 0,
    );
    await tester.pump();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(target.selectedWordRef, isNull);
    expect(target.clearCallCount, 1);
  });

  testWidgets(
      'dispose preserves a different selection after bridge ownership moves',
      (tester) async {
    final target = _FakeSelectionTarget();
    final container = await _pumpBridge(
      tester,
      selectionTarget: target,
      lookupAyahByUq: (_) => _ayah(),
    );

    container.read(_testMuallimHighlightProvider.notifier).state =
        const MuallimWordHighlight(
      ayahUQNumber: 7,
      wordIndex: 0,
    );
    await tester.pump();

    target.setSelectedWord(
      const WordRef(
        surahNumber: 9,
        ayahNumber: 1,
        wordNumber: 1,
      ),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(
      target.selectedWordRef,
      const WordRef(
        surahNumber: 9,
        ayahNumber: 1,
        wordNumber: 1,
      ),
    );
    expect(target.clearCallCount, 0);
  });
}

Future<ProviderContainer> _pumpBridge(
  WidgetTester tester, {
  required MuallimWordSelectionTarget selectionTarget,
  required MuallimAyahLookup lookupAyahByUq,
}) async {
  final container = ProviderContainer(
    overrides: [
      muallimWordHighlightProvider.overrideWith(
        (ref) => ref.watch(_testMuallimHighlightProvider),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: MuallimWordHighlightBridge(
          selectionTarget: selectionTarget,
          lookupAyahByUq: lookupAyahByUq,
          child: const SizedBox(),
        ),
      ),
    ),
  );
  await tester.pump();

  return container;
}

AyahModel _ayah({
  int ayahUQNumber = 7,
  int surahNumber = 2,
  int ayahNumber = 255,
}) {
  return AyahModel(
    ayahUQNumber: ayahUQNumber,
    ayahNumber: ayahNumber,
    text: 'word',
    ayaTextEmlaey: 'word',
    juz: 3,
    page: 42,
    surahNumber: surahNumber,
  );
}

class _FakeSelectionTarget implements MuallimWordSelectionTarget {
  @override
  WordRef? selectedWordRef;

  int setCallCount = 0;
  int clearCallCount = 0;

  @override
  void clearSelectedWord() {
    clearCallCount++;
    selectedWordRef = null;
  }

  @override
  void setSelectedWord(WordRef ref) {
    setCallCount++;
    selectedWordRef = ref;
  }
}

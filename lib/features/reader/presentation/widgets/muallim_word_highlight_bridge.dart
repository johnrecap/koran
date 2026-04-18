import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/features/reader/providers/muallim_providers.dart';
import 'package:quran_library/quran_library.dart';

typedef MuallimAyahLookup = AyahModel Function(int ayahUQNumber);

abstract interface class MuallimWordSelectionTarget {
  WordRef? get selectedWordRef;
  void setSelectedWord(WordRef ref);
  void clearSelectedWord();
}

class QuranLibraryWordSelectionTarget implements MuallimWordSelectionTarget {
  QuranLibraryWordSelectionTarget({WordInfoCtrl? controller})
      : _controller = controller ?? WordInfoCtrl.instance;

  final WordInfoCtrl _controller;

  @override
  WordRef? get selectedWordRef => _controller.selectedWordRef.value;

  @override
  void clearSelectedWord() => _controller.clearSelectedWord();

  @override
  void setSelectedWord(WordRef ref) => _controller.setSelectedWord(ref);
}

WordRef? resolveMuallimHighlightedWordRef({
  required MuallimWordHighlight highlight,
  required MuallimAyahLookup lookupAyahByUq,
}) {
  final ayahUQNumber = highlight.ayahUQNumber;
  final wordIndex = highlight.wordIndex;
  if (ayahUQNumber == null || wordIndex == null || wordIndex < 0) {
    return null;
  }

  final ayah = lookupAyahByUq(ayahUQNumber);
  final surahNumber = ayah.surahNumber;
  if (surahNumber == null || surahNumber <= 0 || ayah.ayahNumber <= 0) {
    return null;
  }

  return WordRef(
    surahNumber: surahNumber,
    ayahNumber: ayah.ayahNumber,
    wordNumber: wordIndex + 1,
  );
}

class MuallimWordHighlightBridge extends ConsumerStatefulWidget {
  const MuallimWordHighlightBridge({
    super.key,
    required this.child,
    this.lookupAyahByUq,
    this.selectionTarget,
  });

  final Widget child;
  final MuallimAyahLookup? lookupAyahByUq;
  final MuallimWordSelectionTarget? selectionTarget;

  @override
  ConsumerState<MuallimWordHighlightBridge> createState() =>
      _MuallimWordHighlightBridgeState();
}

class _MuallimWordHighlightBridgeState
    extends ConsumerState<MuallimWordHighlightBridge> {
  WordRef? _lastAppliedWordRef;
  late final ProviderSubscription<MuallimWordHighlight> _subscription;
  late final MuallimWordSelectionTarget _defaultSelectionTarget =
      QuranLibraryWordSelectionTarget();

  MuallimAyahLookup get _lookupAyahByUq =>
      widget.lookupAyahByUq ?? QuranCtrl.instance.getAyahByUq;

  MuallimWordSelectionTarget get _selectionTarget =>
      widget.selectionTarget ?? _defaultSelectionTarget;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<MuallimWordHighlight>(
      muallimWordHighlightProvider,
      (previous, next) => _syncHighlight(next),
      fireImmediately: true,
    );
  }

  void _syncHighlight(MuallimWordHighlight highlight) {
    final nextRef = resolveMuallimHighlightedWordRef(
      highlight: highlight,
      lookupAyahByUq: _lookupAyahByUq,
    );
    if (nextRef == null) {
      _clearBridgeOwnedSelection();
      return;
    }

    if (_lastAppliedWordRef == nextRef &&
        _selectionTarget.selectedWordRef == nextRef) {
      return;
    }

    _selectionTarget.setSelectedWord(nextRef);
    _lastAppliedWordRef = nextRef;
  }

  void _clearBridgeOwnedSelection() {
    final lastAppliedWordRef = _lastAppliedWordRef;
    if (lastAppliedWordRef == null) {
      return;
    }

    if (_selectionTarget.selectedWordRef == lastAppliedWordRef) {
      _selectionTarget.clearSelectedWord();
    }
    _lastAppliedWordRef = null;
  }

  @override
  void dispose() {
    _subscription.close();
    _clearBridgeOwnedSelection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

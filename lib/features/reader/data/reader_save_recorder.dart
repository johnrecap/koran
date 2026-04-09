import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/memorization/data/reading_session.dart';
import 'package:quran_kareem/features/reader/domain/reader_session_intent.dart';

class ReaderSaveRecorder {
  ReaderSaveRecorder({
    required Future<void> Function(ReadingPosition position)
        saveLastReadingPosition,
    required Future<void> Function(ReadingSession session) upsertSession,
    required Future<void> Function({
      required String khatmaId,
      required int pageNumber,
      required DateTime timestamp,
    }) recordKhatmaProgress,
    required Future<String> Function(int surahNumber) resolveSurahName,
    required ReaderSessionIntent Function() loadReaderSessionIntent,
    required void Function() onSaved,
    DateTime Function()? now,
  })  : _saveLastReadingPosition = saveLastReadingPosition,
        _upsertSession = upsertSession,
        _recordKhatmaProgress = recordKhatmaProgress,
        _resolveSurahName = resolveSurahName,
        _loadReaderSessionIntent = loadReaderSessionIntent,
        _onSaved = onSaved,
        _now = now ?? DateTime.now;

  final Future<void> Function(ReadingPosition position)
      _saveLastReadingPosition;
  final Future<void> Function(ReadingSession session) _upsertSession;
  final Future<void> Function({
    required String khatmaId,
    required int pageNumber,
    required DateTime timestamp,
  }) _recordKhatmaProgress;
  final Future<String> Function(int surahNumber) _resolveSurahName;
  final ReaderSessionIntent Function() _loadReaderSessionIntent;
  final void Function() _onSaved;
  final DateTime Function() _now;

  Future<void> record({
    required String sessionId,
    required int surahNumber,
    required int ayahNumber,
    required int page,
    bool allowKhatmaTracking = true,
  }) async {
    final savedAt = _now();
    final position = ReadingPosition(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      page: page,
      savedAt: savedAt,
    );
    await _saveLastReadingPosition(position);

    final surahName = await _resolveSurahName(surahNumber);
    await _upsertSession(
      ReadingSession(
        id: sessionId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        surahName: surahName,
        timestamp: savedAt,
      ),
    );

    final sessionIntent = _loadReaderSessionIntent();
    final trackedKhatmaId = sessionIntent.trackedKhatmaId;
    if (allowKhatmaTracking && trackedKhatmaId != null) {
      await _upsertSession(
        ReadingSession(
          id: 'khatma-$trackedKhatmaId',
          surahNumber: surahNumber,
          ayahNumber: ayahNumber,
          surahName: surahName,
          timestamp: savedAt,
          khatmaId: trackedKhatmaId,
          isTrustedKhatmaAnchor: true,
        ),
      );
      await _recordKhatmaProgress(
        khatmaId: trackedKhatmaId,
        pageNumber: page,
        timestamp: savedAt,
      );
    }

    _onSaved();
  }
}

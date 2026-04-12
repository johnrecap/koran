import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/storage_keys.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/data/datasources/local/user_preferences.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';

final ayahNotesProvider =
    StateNotifierProvider<AyahNotesNotifier, Map<String, AyahNote>>(
  (ref) => AyahNotesNotifier(),
);

class AyahNotesNotifier extends StateNotifier<Map<String, AyahNote>> {
  AyahNotesNotifier() : super(const <String, AyahNote>{}) {
    ready = _load();
  }

  static const _storageKey = StorageKeys.ayahNotes;
  late final Future<void> ready;

  static String noteKeyFor(int surahNumber, int ayahNumber) {
    return '$surahNumber:$ayahNumber';
  }

  AyahNote? noteFor(int surahNumber, int ayahNumber) {
    return state[noteKeyFor(surahNumber, ayahNumber)];
  }

  Future<void> saveNote({
    required int surahNumber,
    required int ayahNumber,
    required String content,
  }) async {
    final normalized = content.trim();
    if (normalized.isEmpty) {
      await deleteNote(surahNumber: surahNumber, ayahNumber: ayahNumber);
      return;
    }

    final existing = noteFor(surahNumber, ayahNumber);
    final nextState = Map<String, AyahNote>.from(state)
      ..[noteKeyFor(surahNumber, ayahNumber)] = AyahNote(
        id: _stableIdFor(surahNumber, ayahNumber),
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        content: normalized,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

    state = nextState;
    await _save();
  }

  Future<void> deleteNote({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final key = noteKeyFor(surahNumber, ayahNumber);
    if (!state.containsKey(key)) {
      return;
    }

    final nextState = Map<String, AyahNote>.from(state)..remove(key);
    state = nextState;
    await _save();
  }

  Future<void> _load() async {
    final prefs = await UserPreferences.prefs;
    final rawJson = prefs.getString(_storageKey);
    if (rawJson == null || rawJson.isEmpty) {
      state = const <String, AyahNote>{};
      return;
    }

    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      state = decoded.map(
        (key, value) => MapEntry(
          key,
          _noteFromMap(value as Map<String, dynamic>),
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('AyahNotesNotifier._load', error, stackTrace);
      state = const <String, AyahNote>{};
    }
  }

  Future<void> _save() async {
    final prefs = await UserPreferences.prefs;
    final payload = state.map(
      (key, note) => MapEntry(key, _noteToMap(note)),
    );
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  static int _stableIdFor(int surahNumber, int ayahNumber) {
    return (surahNumber * 1000) + ayahNumber;
  }

  static Map<String, dynamic> _noteToMap(AyahNote note) {
    return <String, dynamic>{
      'id': note.id,
      'surahNumber': note.surahNumber,
      'ayahNumber': note.ayahNumber,
      'content': note.content,
      'createdAt': note.createdAt.toIso8601String(),
      'updatedAt': note.updatedAt.toIso8601String(),
    };
  }

  static AyahNote _noteFromMap(Map<String, dynamic> map) {
    return AyahNote(
      id: map['id'] as int,
      surahNumber: map['surahNumber'] as int,
      ayahNumber: map['ayahNumber'] as int,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}

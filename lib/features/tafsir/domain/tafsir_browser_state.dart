import 'package:quran_kareem/features/reader/domain/reader_ayah_insights_policy.dart';

import 'tafsir_browser_source_option.dart';

export 'tafsir_browser_source_option.dart';

class TafsirBrowserState {
  const TafsirBrowserState({
    required this.target,
    required this.sourceOptions,
    required this.content,
  });

  final ReaderAyahInsightsTarget target;
  final List<TafsirBrowserSourceOption> sourceOptions;
  final TafsirBrowserContentState content;

  TafsirBrowserState copyWith({
    ReaderAyahInsightsTarget? target,
    List<TafsirBrowserSourceOption>? sourceOptions,
    TafsirBrowserContentState? content,
  }) {
    return TafsirBrowserState(
      target: target ?? this.target,
      sourceOptions: sourceOptions ?? this.sourceOptions,
      content: content ?? this.content,
    );
  }
}

sealed class TafsirBrowserContentState {
  const TafsirBrowserContentState();
}

class TafsirBrowserFootnote {
  const TafsirBrowserFootnote({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TafsirBrowserFootnote &&
            other.number == number &&
            other.text == text);
  }

  @override
  int get hashCode => Object.hash(number, text);
}

class TafsirBrowserLoadedContent extends TafsirBrowserContentState {
  const TafsirBrowserLoadedContent({
    required this.verseText,
    required this.bodyText,
    this.footnotes = const [],
  });

  final String verseText;
  final String bodyText;
  final List<TafsirBrowserFootnote> footnotes;
}

class TafsirBrowserSourceUnavailableContent extends TafsirBrowserContentState {
  const TafsirBrowserSourceUnavailableContent();
}

class TafsirBrowserErrorContent extends TafsirBrowserContentState {
  const TafsirBrowserErrorContent({
    required this.error,
  });

  final Object error;
}

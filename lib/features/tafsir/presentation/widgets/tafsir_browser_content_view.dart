import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/features/tafsir/domain/tafsir_browser_state.dart';

class TafsirBrowserContentView extends StatelessWidget {
  const TafsirBrowserContentView({
    super.key,
    required this.contentState,
  })  : content = null,
        isScrollControlled = true;

  const TafsirBrowserContentView.section({
    super.key,
    required TafsirBrowserLoadedContent this.content,
  })  : contentState = null,
        isScrollControlled = false;

  final AsyncValue<TafsirBrowserContentState>? contentState;
  final TafsirBrowserLoadedContent? content;
  final bool isScrollControlled;

  @override
  Widget build(BuildContext context) {
    final loadedContent = content;
    if (loadedContent != null) {
      return _LoadedContentView(
        content: loadedContent,
        isScrollControlled: isScrollControlled,
      );
    }

    final asyncState = contentState!;
    return asyncState.when(
      loading: () => Center(
        child: Text(context.l10n.tafsirBrowserLoading),
      ),
      error: (_, __) => Center(
        child: Text(context.l10n.tafsirBrowserLoadError),
      ),
      data: (state) => switch (state) {
        TafsirBrowserLoadedContent() => _LoadedContentView(
            content: state,
            isScrollControlled: isScrollControlled,
          ),
        TafsirBrowserSourceUnavailableContent() => Center(
            child: Text(context.l10n.tafsirBrowserSourceUnavailable),
          ),
        TafsirBrowserErrorContent() => Center(
            child: Text(context.l10n.tafsirBrowserLoadError),
          ),
      },
    );
  }
}

class _LoadedContentView extends StatelessWidget {
  const _LoadedContentView({
    required this.content,
    required this.isScrollControlled,
  });

  final TafsirBrowserLoadedContent content;
  final bool isScrollControlled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final body = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (content.verseText.trim().isNotEmpty)
            Text(
              content.verseText,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.8,
              ),
            ),
          if (content.verseText.trim().isNotEmpty) const SizedBox(height: 16),
          Text(
            content.bodyText,
            style: textTheme.bodyLarge?.copyWith(height: 1.9),
          ),
          if (content.footnotes.isNotEmpty) const SizedBox(height: 24),
          if (content.footnotes.isNotEmpty)
            Text(
              context.l10n.tafsirBrowserFootnotesTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          if (content.footnotes.isNotEmpty) const SizedBox(height: 12),
          for (final footnote in content.footnotes)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                '(${footnote.number}) ${footnote.text}',
                style: textTheme.bodyMedium?.copyWith(height: 1.7),
              ),
            ),
        ],
      ),
    );

    if (isScrollControlled) {
      return SingleChildScrollView(child: body);
    }

    return body;
  }
}

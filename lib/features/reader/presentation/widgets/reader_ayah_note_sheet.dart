import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/reader/providers/ayah_notes_provider.dart';

enum ReaderAyahNoteSheetResult { saved, deleted }

Future<ReaderAyahNoteSheetResult?> showReaderAyahNoteSheet({
  required BuildContext context,
  required Ayah ayah,
}) {
  return showModalBottomSheet<ReaderAyahNoteSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReaderAyahNoteSheet(ayah: ayah),
  );
}

class ReaderAyahNoteSheet extends ConsumerStatefulWidget {
  const ReaderAyahNoteSheet({
    super.key,
    required this.ayah,
  });

  final Ayah ayah;

  @override
  ConsumerState<ReaderAyahNoteSheet> createState() =>
      _ReaderAyahNoteSheetState();
}

class _ReaderAyahNoteSheetState extends ConsumerState<ReaderAyahNoteSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _didSeedInitialValue = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _seedInitialValue(String? content) {
    if (_didSeedInitialValue) {
      return;
    }
    _controller.text = content ?? '';
    _didSeedInitialValue = true;
  }

  void _popWithResult(ReaderAyahNoteSheetResult result) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.read(ayahNotesProvider.notifier);
    final notes = ref.watch(ayahNotesProvider);
    final existingNote = notes[
        AyahNotesNotifier.noteKeyFor(
          widget.ayah.surahNumber,
          widget.ayah.ayahNumber,
        )];
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final backgroundColor = isDark
        ? AppColors.surfaceDarkNav
        : Colors.white.withValues(alpha: 0.98);

    return FutureBuilder<void>(
      future: notifier.ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          _seedInitialValue(existingNote?.content);
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 12, 12, bottomInset + 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.24)
                              : Colors.black.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      context.l10n.verseActionNote,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textDark
                            : AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 18),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.04)
                            : AppColors.camel.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : AppColors.gold.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Text(
                                    '${context.l10n.verseActionAyah} ${widget.ayah.ayahNumber}',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.ayah.text,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontFamily: 'ScheherazadeNew',
                                fontSize: 28,
                                height: 1.8,
                                color: isDark
                                    ? AppColors.textDark
                                    : AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: 18),
                            if (snapshot.connectionState != ConnectionState.done)
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      context.l10n.verseNoteLoading,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark
                                            ? Colors.white70
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              TextField(
                                key: const ValueKey<String>('ayah-note-field'),
                                controller: _controller,
                                maxLines: 6,
                                minLines: 4,
                                onChanged: (_) => setState(() {}),
                                textDirection: Directionality.of(context),
                                decoration: InputDecoration(
                                  hintText: context.l10n.verseNoteHint,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _controller.text.trim().isEmpty
                                          ? null
                                          : () async {
                                              await notifier.saveNote(
                                                surahNumber:
                                                    widget.ayah.surahNumber,
                                                ayahNumber:
                                                    widget.ayah.ayahNumber,
                                                content: _controller.text,
                                              );
                                              if (!mounted) {
                                                return;
                                              }
                                              _popWithResult(
                                                ReaderAyahNoteSheetResult.saved,
                                              );
                                            },
                                      child: Text(
                                        context.l10n.verseNoteSave,
                                      ),
                                    ),
                                  ),
                                  if (existingNote != null) ...[
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          await notifier.deleteNote(
                                            surahNumber:
                                                widget.ayah.surahNumber,
                                            ayahNumber: widget.ayah.ayahNumber,
                                          );
                                          if (!mounted) {
                                            return;
                                          }
                                          _controller.clear();
                                          _popWithResult(
                                            ReaderAyahNoteSheetResult.deleted,
                                          );
                                        },
                                        child: Text(
                                          context.l10n.verseNoteDelete,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

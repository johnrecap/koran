import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/data/datasources/local/quran_database.dart';
import 'package:quran_kareem/features/reader/domain/reader_navigation_target.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

/// Quick jump dialog for choosing a target surah and ayah.
class JumpToDialog extends ConsumerStatefulWidget {
  const JumpToDialog({super.key});

  @override
  ConsumerState<JumpToDialog> createState() => _JumpToDialogState();
}

class _JumpToDialogState extends ConsumerState<JumpToDialog> {
  int _selectedSurah = 1;
  int _selectedAyah = 1;
  int _maxAyah = 7;

  @override
  void initState() {
    super.initState();
    _selectedSurah = ref.read(currentSurahProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surahsAsync = ref.watch(surahsProvider);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shortcut_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'انتقال سريع',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            surahsAsync.when(
              data: (surahs) {
                if (_selectedSurah <= surahs.length) {
                  _maxAyah = surahs[_selectedSurah - 1].ayahCount;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'السورة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDarkNav
                            : AppColors.camel.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedSurah,
                          isExpanded: true,
                          dropdownColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.surfaceLight,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: isDark
                                ? AppColors.textDark
                                : AppColors.textLight,
                          ),
                          items: surahs.map((surah) {
                            return DropdownMenuItem<int>(
                              value: surah.number,
                              child: Text(
                                '${surah.number}. ${surah.nameArabic}',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  color: isDark
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            setState(() {
                              _selectedSurah = value;
                              _maxAyah = surahs[value - 1].ayahCount;
                              if (_selectedAyah > _maxAyah) {
                                _selectedAyah = 1;
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'رقم الآية',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.surfaceDarkNav
                            : AppColors.camel.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            color: AppColors.gold,
                            onPressed: _selectedAyah > 1
                                ? () => setState(() => _selectedAyah--)
                                : null,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '$_selectedAyah / $_maxAyah',
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textDark
                                      : AppColors.textLight,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            color: AppColors.gold,
                            onPressed: _selectedAyah < _maxAyah
                                ? () => setState(() => _selectedAyah++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
              error: (_, __) => const Text('خطأ'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textMuted,
                      side: BorderSide(
                        color: AppColors.textMuted.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(fontFamily: 'Amiri'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pageNumber = await QuranDatabase.getPageForAyah(
                        _selectedSurah,
                        _selectedAyah,
                      );
                      if (!context.mounted) {
                        return;
                      }

                      Navigator.of(context).pop(
                        ReaderNavigationTarget(
                          surahNumber: _selectedSurah,
                          ayahNumber: _selectedAyah,
                          pageNumber: pageNumber,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'انتقال',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:quran_kareem/core/constants/app_colors.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';

/// Dialog to create a new khatma with target days selection.
class NewKhatmaDialog extends StatefulWidget {
  const NewKhatmaDialog({
    super.key,
    required this.onCreate,
  });

  final void Function(String title, int targetDays) onCreate;

  @override
  State<NewKhatmaDialog> createState() => _NewKhatmaDialogState();
}

class _NewKhatmaDialogState extends State<NewKhatmaDialog> {
  final _titleController = TextEditingController();
  int _selectedDays = 30;
  bool _didSeedDefaultTitle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didSeedDefaultTitle) {
      return;
    }

    _titleController.text = context.l10n.memorizationNewKhatmaDialogTitle;
    _didSeedDefaultTitle = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final options = [
      (days: 7, label: l10n.memorizationNewKhatmaOptionWeek),
      (days: 10, label: l10n.memorizationNewKhatmaOptionTenDays),
      (days: 15, label: l10n.memorizationNewKhatmaOptionFifteenDays),
      (days: 30, label: l10n.memorizationNewKhatmaOptionMonth),
      (days: 60, label: l10n.memorizationNewKhatmaOptionTwoMonths),
    ];

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.memorizationNewKhatmaDialogTitle,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
                decoration: InputDecoration(
                  labelText: l10n.memorizationNewKhatmaNameLabel,
                  labelStyle: const TextStyle(
                    fontFamily: 'Amiri',
                    color: AppColors.textMuted,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.surfaceDarkNav
                      : AppColors.camel.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.memorizationNewKhatmaDurationLabel,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 14,
                  color: isDark ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: options.map((option) {
                  final isSelected = _selectedDays == option.days;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDays = option.days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold
                            : (isDark
                                ? AppColors.surfaceDarkNav
                                : AppColors.camel.withValues(alpha: 0.08)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w400,
                          color:
                              isSelected ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onCreate(_titleController.text, _selectedDays);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    l10n.memorizationNewKhatmaStart,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

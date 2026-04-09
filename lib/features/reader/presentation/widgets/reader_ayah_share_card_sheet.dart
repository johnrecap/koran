import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_kareem/core/localization/app_localizations.dart';
import 'package:quran_kareem/core/utils/app_logger.dart';
import 'package:quran_kareem/domain/entities/quran_entities.dart';
import 'package:quran_kareem/features/premium/domain/paywall_entry_context.dart';
import 'package:quran_kareem/features/premium/presentation/widgets/premium_paywall_sheet.dart';
import 'package:quran_kareem/features/premium/providers/premium_providers.dart';
import 'package:quran_kareem/features/reader/domain/ayah_translation.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';
import 'package:quran_kareem/features/reader/presentation/widgets/ayah_share_card_preview.dart';
import 'package:quran_kareem/features/reader/providers/ayah_share_card_providers.dart';
import 'package:quran_kareem/features/reader/providers/reader_providers.dart';

Future<void> showReaderAyahShareCardSheet({
  required BuildContext context,
  required AyahShareCardPayload payload,
  Ayah? ayah,
  bool allowTranslationToggle = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReaderAyahShareCardSheet(
      ayah: ayah,
      allowTranslationToggle: allowTranslationToggle,
      payload: payload,
    ),
  );
}

class ReaderAyahShareCardSheet extends ConsumerStatefulWidget {
  const ReaderAyahShareCardSheet({
    super.key,
    required this.payload,
    this.ayah,
    this.allowTranslationToggle = true,
  });

  final AyahShareCardPayload payload;
  final Ayah? ayah;
  final bool allowTranslationToggle;

  @override
  ConsumerState<ReaderAyahShareCardSheet> createState() =>
      _ReaderAyahShareCardSheetState();
}

class _ReaderAyahShareCardSheetState
    extends ConsumerState<ReaderAyahShareCardSheet> {
  final GlobalKey _previewBoundaryKey = GlobalKey();
  String? _selectedTemplateId;
  bool _includeTranslation = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final templates = ref.watch(ayahShareCardTemplatesProvider);
    final previewWidth =
        (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 320.0).toDouble();
    final translationsAsync =
        widget.ayah == null || !widget.allowTranslationToggle
            ? const AsyncValue<Map<int, AyahTranslation>>.data(
                <int, AyahTranslation>{},
              )
            : ref.watch(surahTranslationsProvider(widget.ayah!.surahNumber));
    if (templates.isEmpty) {
      return Center(
        child: Text(l10n.ayahShareCardMissingTemplate),
      );
    }

    final selectedTemplate = templates.firstWhere(
      (template) => template.id == _selectedTemplateId,
      orElse: () => templates.first,
    );
    final entitlementSnapshot = ref.watch(premiumEntitlementControllerProvider);
    final resolvedPayload = _resolvePayload(translationsAsync);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.ayahShareCardTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ayahShareCardSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                ),
                const SizedBox(height: 20),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: previewWidth),
                  child: Center(
                    child: SizedBox(
                      width: previewWidth,
                      child: RepaintBoundary(
                        key: _previewBoundaryKey,
                        child: AyahShareCardPreview(
                          template: selectedTemplate,
                          payload: resolvedPayload,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                if (widget.ayah != null && widget.allowTranslationToggle)
                  _buildTranslationControl(
                    translationsAsync: translationsAsync,
                    l10n: l10n,
                  ),
                if (widget.ayah != null && widget.allowTranslationToggle)
                  const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final template in templates)
                      _TemplateChip(
                        template: template,
                        isSelected: template.id == selectedTemplate.id,
                        isUnlocked: template.requiredAccessKey == null ||
                            entitlementSnapshot.hasAccess(
                              template.requiredAccessKey!,
                            ),
                        label: l10n.ayahShareCardTemplateName(template.id),
                        onTap: () => _handleTemplateTap(template),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _isSharing
                      ? null
                      : () => _handleShare(
                            template: selectedTemplate,
                            payload: resolvedPayload,
                          ),
                  child: Text(
                    _isSharing
                        ? l10n.ayahShareCardPreparing
                        : l10n.ayahShareCardShareAction,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleShare({
    required AyahShareCardTemplate template,
    required AyahShareCardPayload payload,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() {
      _isSharing = true;
    });

    try {
      final exportService = ref.read(ayahShareCardExportServiceProvider);
      final shareService = ref.read(ayahShareCardShareServiceProvider);
      final result = await exportService.export(
        repaintBoundaryKey: _previewBoundaryKey,
        template: template,
        payload: payload,
      );
      await shareService.share(result);
    } on StateError {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ayahShareCardExportUnavailable)),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'ReaderAyahShareCardSheet._handleShare',
        error,
        stackTrace,
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.ayahShareCardShareUnavailable)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _handleTemplateTap(AyahShareCardTemplate template) async {
    final requiredAccessKey = template.requiredAccessKey;
    final hasAccess = requiredAccessKey == null
        ? true
        : ref.read(hasPremiumAccessProvider(requiredAccessKey));
    if (hasAccess) {
      setState(() {
        _selectedTemplateId = template.id;
      });
      return;
    }

    final unlocked = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => PremiumPaywallSheet(
            contextInfo: PaywallEntryContext.lockedAyahShareTemplate(
              templateId: template.id,
            ),
            autoCloseOnUnlock: true,
          ),
        ) ??
        false;
    if (!mounted || !unlocked) {
      return;
    }

    setState(() {
      _selectedTemplateId = template.id;
    });
  }

  AyahShareCardPayload _resolvePayload(
    AsyncValue<Map<int, AyahTranslation>> translationsAsync,
  ) {
    if (!widget.allowTranslationToggle || widget.ayah == null) {
      return widget.payload;
    }

    if (!_includeTranslation) {
      return widget.payload.copyWith(supportingText: null);
    }

    return translationsAsync.when(
      data: (translations) {
        final translation = translations[widget.ayah!.ayahNumber];
        return widget.payload.copyWith(
          supportingText: translation?.text,
        );
      },
      loading: () => widget.payload.copyWith(supportingText: null),
      error: (_, __) => widget.payload.copyWith(supportingText: null),
    );
  }

  Widget _buildTranslationControl({
    required AsyncValue<Map<int, AyahTranslation>> translationsAsync,
    required AppLocalizations l10n,
  }) {
    final ayah = widget.ayah!;

    return translationsAsync.when(
      data: (translations) {
        final translation = translations[ayah.ayahNumber];
        if (translation == null) {
          return Text(
            l10n.translationVerseFallback,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.72),
                ),
          );
        }

        return SwitchListTile.adaptive(
          key: const ValueKey<String>('ayah-share-translation-toggle'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.ayahShareCardTranslationToggle),
          value: _includeTranslation,
          onChanged: (value) {
            setState(() {
              _includeTranslation = value;
            });
          },
        );
      },
      loading: () => Text(
        l10n.translationModeLoading,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.72,
                  ),
            ),
      ),
      error: (_, __) => Text(
        l10n.translationModeError,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.72,
                  ),
            ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.isSelected,
    required this.isUnlocked,
    required this.label,
    required this.onTap,
  });

  final AyahShareCardTemplate template;
  final bool isSelected;
  final bool isUnlocked;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      key: ValueKey<String>('ayah-share-template-${template.id}'),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isUnlocked) ...[
            const Icon(Icons.lock_outline, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
    );
  }
}

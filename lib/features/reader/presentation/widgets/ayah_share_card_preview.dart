import 'package:flutter/material.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_payload.dart';
import 'package:quran_kareem/features/reader/domain/ayah_share_card_template.dart';

class AyahShareCardPreview extends StatelessWidget {
  const AyahShareCardPreview({
    super.key,
    required this.template,
    required this.payload,
  });

  final AyahShareCardTemplate template;
  final AyahShareCardPayload payload;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: template.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          key: ValueKey<String>('ayah-share-preview-${template.id}'),
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                template.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return DecoratedBox(
                    key: ValueKey<String>(
                      'ayah-share-background-fallback-${template.id}',
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          template.ayahSlot.textColor.withValues(alpha: 0.12),
                          template.referenceSlot.textColor
                              .withValues(alpha: 0.18),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  );
                },
              ),
            ),
            _PreviewTextBlock(
              text: payload.ayahText,
              textDirection: TextDirection.rtl,
              textStyle: TextStyle(
                fontFamily: 'Amiri',
                fontSize: template.ayahSlot.fontSize,
                height: 1.8,
                fontWeight: FontWeight.w700,
                color: template.ayahSlot.textColor,
              ),
              slot: template.ayahSlot,
            ),
            _PreviewTextBlock(
              text: payload.referenceText,
              textDirection: Directionality.of(context),
              textStyle: TextStyle(
                fontSize: template.referenceSlot.fontSize,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: template.referenceSlot.textColor,
              ),
              slot: template.referenceSlot,
            ),
            if (payload.hasSupportingText)
              _PreviewTextBlock(
                text: payload.supportingText!,
                textDirection: Directionality.of(context),
                textStyle: TextStyle(
                  fontSize: template.translationSlot.fontSize,
                  height: 1.6,
                  color: template.translationSlot.textColor,
                ),
                slot: template.translationSlot,
              ),
          ],
        ),
      ),
    );
  }
}

class _PreviewTextBlock extends StatelessWidget {
  const _PreviewTextBlock({
    required this.text,
    required this.textDirection,
    required this.textStyle,
    required this.slot,
  });

  final String text;
  final TextDirection textDirection;
  final TextStyle textStyle;
  final AyahShareTextSlot slot;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Padding(
        padding: slot.padding,
        child: Align(
          alignment: slot.alignment,
          child: Text(
            text,
            textAlign: slot.textAlign,
            textDirection: textDirection,
            maxLines: slot.maxLines,
            overflow: TextOverflow.ellipsis,
            style: textStyle,
          ),
        ),
      ),
    );
  }
}

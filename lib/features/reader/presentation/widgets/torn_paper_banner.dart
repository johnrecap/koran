import 'package:flutter/material.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_presentation_policy.dart';
import 'package:quran_kareem/features/reader/domain/reader_night_style.dart';

/// Custom torn-paper/watercolor banner for the Heritage Manuscript design.
/// This is the signature design element — a warm camel banner with
/// an organic irregular torn edge at the bottom.
class TornPaperBanner extends StatelessWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBackPressed;
  final ReaderNightPalette? palette;

  const TornPaperBanner({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.onBackPressed,
    this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedPalette = palette ??
        ReaderNightPresentationPolicy.paletteFor(
          presentation: ReaderNightPresentation.normal,
          appBrightness: Theme.of(context).brightness,
        );
    final bannerColor = resolvedPalette.bannerColor;
    final textColor = resolvedPalette.bannerTextColor;

    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: bannerColor,
      automaticallyImplyLeading: false,
      leading: onMenuPressed != null
          ? IconButton(
              icon: Icon(Icons.menu, color: textColor),
              onPressed: onMenuPressed,
            )
          : null,
      actions: onBackPressed != null
          ? [
              IconButton(
                icon: Icon(Icons.arrow_forward_ios, color: textColor, size: 20),
                onPressed: onBackPressed,
              ),
            ]
          : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 40),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(24),
        child: _TornEdge(color: resolvedPalette.bannerEdgeColor),
      ),
    );
  }
}

/// Paints the organic torn/wavy edge at the bottom of the banner.
/// This creates the signature "torn paper" effect.
class _TornEdge extends StatelessWidget {
  final Color color;

  const _TornEdge({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 24,
      child: CustomPaint(
        painter: _TornEdgePainter(color),
      ),
    );
  }
}

class _TornEdgePainter extends CustomPainter {
  final Color color;
  _TornEdgePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    // Create organic wavy torn edge
    final step = size.width / 20;
    for (int i = 19; i >= 0; i--) {
      final x = i * step;
      // Alternate heights to create torn paper effect
      final y = (i % 3 == 0) ? 8.0 : (i % 3 == 1) ? 2.0 : 12.0;
      if (i == 19) {
        path.lineTo(x, y);
      } else {
        final prevX = (i + 1) * step;
        final midX = (x + prevX) / 2;
        final controlY = (i % 2 == 0) ? 16.0 : 0.0;
        path.quadraticBezierTo(midX, controlY, x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

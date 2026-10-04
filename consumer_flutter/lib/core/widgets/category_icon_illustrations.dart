
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';

/// The 8 catalog categories that need a flat illustrated icon on Home /
/// Category chips — matches the doodle set approved in the Home mockup.
/// These are small custom-painted shapes, not a generic icon-font glyph
/// (Material Symbols outline read as "app chrome" in review, not
/// merchandising) and not emoji.
enum CategoryIllustration {
  fruitsVeg,
  dairy,
  snacks,
  beverages,
  bakery,
  grains,
  masala,
  frozen,
}

class CategoryTile extends StatelessWidget {
  final CategoryIllustration type;
  final String label;
  final VoidCallback? onTap;

  const CategoryTile({
    super.key,
    required this.type,
    required this.label,
    this.onTap,
  });

  Color get _tint {
    switch (type) {
      case CategoryIllustration.fruitsVeg:
        return AppColors.tint1;
      case CategoryIllustration.dairy:
        return AppColors.tint2;
      case CategoryIllustration.snacks:
        return AppColors.tint3;
      case CategoryIllustration.beverages:
        return AppColors.tint4;
      case CategoryIllustration.bakery:
        return AppColors.tint5;
      case CategoryIllustration.grains:
        return AppColors.tint6;
      case CategoryIllustration.masala:
        return AppColors.tint7;
      case CategoryIllustration.frozen:
        return AppColors.tint8;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppRadius.tile),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(13),
            child: CustomPaint(
              painter: _CategoryPainter(type, _tint),
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 62,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPainter extends CustomPainter {
  final CategoryIllustration type;
  final Color tint;
  _CategoryPainter(this.type, this.tint);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..style = PaintingStyle.fill;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w * 0.08;

    switch (type) {
      case CategoryIllustration.fruitsVeg:
        fill.color = const Color(0xFF639922);
        canvas.drawOval(Rect.fromLTWH(0, h * 0.35, w * 0.62, h * 0.55), fill);
        fill.color = const Color(0xFF97C459);
        canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.35, w * 0.58, h * 0.48), fill);
        fill.color = const Color(0xFFD85A30);
        canvas.drawCircle(Offset(w * 0.55, h * 0.12), w * 0.09, fill);
        break;
      case CategoryIllustration.dairy:
        fill.color = const Color(0xFF5DCAA5);
        final p = Path()
          ..moveTo(w * 0.32, h * 0.1)
          ..lineTo(w * 0.68, h * 0.1)
          ..lineTo(w * 0.8, h * 0.32)
          ..lineTo(w * 0.8, h * 0.9)
          ..lineTo(w * 0.2, h * 0.9)
          ..lineTo(w * 0.2, h * 0.32)
          ..close();
        canvas.drawPath(p, fill);
        fill.color = Colors.white.withValues(alpha: 0.55);
        canvas.drawRect(Rect.fromLTWH(w * 0.2, h * 0.48, w * 0.6, h * 0.16), fill);
        break;
      case CategoryIllustration.snacks:
        fill.color = const Color(0xFFF0997B);
        final p = Path()
          ..moveTo(w * 0.22, h * 0.35)
          ..quadraticBezierTo(w * 0.5, h * 0.1, w * 0.78, h * 0.35)
          ..lineTo(w * 0.7, h * 0.92)
          ..lineTo(w * 0.3, h * 0.92)
          ..close();
        canvas.drawPath(p, fill);
        fill.color = const Color(0xFF993C1D);
        canvas.drawCircle(Offset(w * 0.4, h * 0.55), w * 0.05, fill);
        canvas.drawCircle(Offset(w * 0.6, h * 0.68), w * 0.05, fill);
        break;
      case CategoryIllustration.beverages:
        fill.color = const Color(0xFF85B7EB);
        final p = Path()
          ..moveTo(w * 0.34, h * 0.14)
          ..lineTo(w * 0.66, h * 0.14)
          ..lineTo(w * 0.6, h * 0.35)
          ..lineTo(w * 0.6, h * 0.86)
          ..quadraticBezierTo(w * 0.5, h * 0.94, w * 0.4, h * 0.86)
          ..lineTo(w * 0.4, h * 0.35)
          ..close();
        canvas.drawPath(p, fill);
        break;
      case CategoryIllustration.bakery:
        fill.color = const Color(0xFFFAC775);
        final p = Path()
          ..moveTo(w * 0.1, h * 0.68)
          ..quadraticBezierTo(w * 0.5, h * 0.05, w * 0.9, h * 0.68)
          ..close();
        canvas.drawPath(p, fill);
        canvas.drawLine(Offset(w * 0.18, h * 0.72), Offset(w * 0.82, h * 0.72), stroke..color = const Color(0xFF854F0B));
        break;
      case CategoryIllustration.grains:
        fill.color = const Color(0xFFF1EFE8);
        canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.42, w * 0.8, h * 0.4), fill);
        fill.color = Colors.white;
        canvas.drawOval(Rect.fromLTWH(w * 0.14, h * 0.4, w * 0.72, h * 0.22), fill);
        break;
      case CategoryIllustration.masala:
        fill.color = const Color(0xFFF09595);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.28, h * 0.32, w * 0.44, h * 0.5), Radius.circular(w * 0.06)),
          fill,
        );
        canvas.drawLine(Offset(w * 0.4, h * 0.32), Offset(w * 0.4, h * 0.2), stroke..color = const Color(0xFFA32D2D));
        canvas.drawLine(Offset(w * 0.6, h * 0.32), Offset(w * 0.6, h * 0.2), stroke..color = const Color(0xFFA32D2D));
        break;
      case CategoryIllustration.frozen:
        stroke.color = const Color(0xFF85B7EB);
        stroke.strokeWidth = w * 0.1;
        canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.9), stroke);
        canvas.drawLine(Offset(w * 0.15, h * 0.3), Offset(w * 0.85, h * 0.7), stroke);
        canvas.drawLine(Offset(w * 0.85, h * 0.3), Offset(w * 0.15, h * 0.7), stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CategoryPainter oldDelegate) => false;
}

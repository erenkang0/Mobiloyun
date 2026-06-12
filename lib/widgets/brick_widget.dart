import 'package:flutter/material.dart';
import '../models/brick.dart';

class BrickWidget extends StatelessWidget {
  final Brick brick;
  final double cellSize;
  final bool isSelected;
  final VoidCallback? onTap;

  const BrickWidget({
    super.key,
    required this.brick,
    required this.cellSize,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = brick.effectiveWidth * cellSize;
    final h = brick.effectiveHeight * cellSize;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: brick.color,
          borderRadius: BorderRadius.circular(4),
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.black26, width: 1),
          boxShadow: [
            BoxShadow(
              color: _darken(brick.color, 0.3),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
            if (isSelected)
              const BoxShadow(
                color: Colors.white38,
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CustomPaint(
            painter: StudPainter(
              cols: brick.effectiveWidth,
              rows: brick.effectiveHeight,
              color: brick.color,
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }
}

class StudPainter extends CustomPainter {
  final int cols;
  final int rows;
  final Color color;

  const StudPainter({required this.cols, required this.rows, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final studR = (size.width / cols) * 0.27;
    final highlightPaint = Paint()
      ..color = _lighten(color, 0.18)
      ..style = PaintingStyle.fill;
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..style = PaintingStyle.fill;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = (c + 0.5) * size.width / cols;
        final cy = (r + 0.5) * size.height / rows;
        canvas.drawCircle(Offset(cx + 1, cy + 2), studR, shadowPaint);
        canvas.drawCircle(Offset(cx, cy), studR, highlightPaint);
      }
    }
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(covariant StudPainter old) =>
      old.cols != cols || old.rows != rows || old.color != color;
}

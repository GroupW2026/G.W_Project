import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFF5F9FD);
  static const Color lightBlue1 = Color(0xFFDCE8F3);
  static const Color lightBlue2 = Color(0xFFB5CDE5);
  static const Color lightBlue3 = Color(0xFF84B0D6);
  static const Color mediumBlue = Color(0xFF4F91C7);
  static const Color primaryBlue = Color(0xFF2B72B5); 
  static const Color darkBlue = Color(0xFF1656A0);
  static const Color darkBlue2 = Color(0xFF0D3C81);
  static const Color navy = Color(0xFF08225E); 
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}

// --- GEOMETRIC BACKGROUND WIDGET ---
class GeometricBackground extends StatelessWidget {
  const GeometricBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Base background color
    paint.color = const Color(0xFFF0F7FF);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Shape 1 (Top Right Diagonal)
    paint.color = const Color(0xFFB5D5F0).withOpacity(0.6);
    final path1 = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.4)
      ..lineTo(size.width * 0.6, 0)
      ..close();
    canvas.drawPath(path1, paint);

    // Shape 2 (Middle Left Polygon)
    paint.color = const Color(0xFF8CBDE2).withOpacity(0.3);
    final path2 = Path()
      ..moveTo(0, size.height * 0.3)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(0, size.height * 0.7)
      ..close();
    canvas.drawPath(path2, paint);

    // Shape 3 (Bottom Right Triangle)
    paint.color = const Color(0xFF6DAEDB).withOpacity(0.2);
    final path3 = Path()
      ..moveTo(size.width, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path3, paint);

    // Thin lines for glass/tech feel
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width * 0.7, 0), linePaint);
    canvas.drawLine(Offset(size.width * 0.3, size.height), Offset(size.width, size.height * 0.6), linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
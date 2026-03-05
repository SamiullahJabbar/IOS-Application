import 'dart:math';
import 'package:flutter/material.dart';

/// Returns the custom-painted futuristic visual widget for each onboarding slide.
class OnboardingVisual extends StatefulWidget {
  final int slideIndex;
  final Color primaryColor;
  final Color secondaryColor;

  const OnboardingVisual({
    super.key,
    required this.slideIndex,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  State<OnboardingVisual> createState() => _OnboardingVisualState();
}

class _OnboardingVisualState extends State<OnboardingVisual>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late AnimationController _dataController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _dataController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotateController,
        _pulseController,
        _dataController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: _VisualPainter(
            slideIndex: widget.slideIndex,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            rotateValue: _rotateController.value,
            pulseValue: _pulseController.value,
            dataValue: _dataController.value,
          ),
          size: const Size(300, 300),
        );
      },
    );
  }
}

class _VisualPainter extends CustomPainter {
  final int slideIndex;
  final Color primaryColor;
  final Color secondaryColor;
  final double rotateValue;
  final double pulseValue;
  final double dataValue;

  _VisualPainter({
    required this.slideIndex,
    required this.primaryColor,
    required this.secondaryColor,
    required this.rotateValue,
    required this.pulseValue,
    required this.dataValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (slideIndex) {
      case 0:
        _paintScanVisual(canvas, size, center);
        break;
      case 1:
        _paintCustomizeVisual(canvas, size, center);
        break;
      case 2:
        _paintPreviewVisual(canvas, size, center);
        break;
    }
  }

  // ─── SLIDE 1: LiDAR Scanning Reticle ────────────────────────────────
  void _paintScanVisual(Canvas canvas, Size size, Offset center) {
    final maxRadius = size.width * 0.42;

    // Outer glow ring
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.0),
          primaryColor.withValues(alpha: 0.08 + pulseValue * 0.06),
          primaryColor.withValues(alpha: 0.0),
        ],
        stops: const [0.6, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius * 1.2));
    canvas.drawCircle(center, maxRadius * 1.2, glowPaint);

    // Rotating dashed rings
    for (int ring = 0; ring < 3; ring++) {
      final radius = maxRadius * (0.55 + ring * 0.2);
      final ringPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.15 + ring * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final angle = rotateValue * 2 * pi * (ring.isEven ? 1 : -1);
      _drawDashedCircle(canvas, center, radius, ringPaint, angle, 24 + ring * 8);
    }

    // Scanning crosshair
    final crosshairPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    final crossLen = maxRadius * 0.35;
    final gap = maxRadius * 0.1;
    // horizontal
    canvas.drawLine(
        Offset(center.dx - crossLen, center.dy),
        Offset(center.dx - gap, center.dy),
        crosshairPaint);
    canvas.drawLine(
        Offset(center.dx + gap, center.dy),
        Offset(center.dx + crossLen, center.dy),
        crosshairPaint);
    // vertical
    canvas.drawLine(
        Offset(center.dx, center.dy - crossLen),
        Offset(center.dx, center.dy - gap),
        crosshairPaint);
    canvas.drawLine(
        Offset(center.dx, center.dy + gap),
        Offset(center.dx, center.dy + crossLen),
        crosshairPaint);

    // Center pulsing dot
    final dotRadius = 4.0 + pulseValue * 3.0;
    canvas.drawCircle(
      center,
      dotRadius,
      Paint()..color = primaryColor.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      center,
      dotRadius + 6,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Floating data points (simulated scan points)
    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final angle = (i / 30) * 2 * pi + dataValue * 2 * pi;
      final dist = maxRadius * (0.2 + random.nextDouble() * 0.6);
      final point = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist,
      );
      final alpha = 0.3 + sin(dataValue * 2 * pi + i) * 0.3;
      canvas.drawCircle(
        point,
        1.5 + random.nextDouble() * 1.5,
        Paint()..color = secondaryColor.withValues(alpha: alpha.clamp(0.1, 0.8)),
      );
    }

    // Corner brackets
    _drawCornerBrackets(canvas, center, maxRadius * 0.75, primaryColor);
  }

  // ─── SLIDE 2: Customize — Color Palette Rings ───────────────────────
  void _paintCustomizeVisual(Canvas canvas, Size size, Offset center) {
    final maxRadius = size.width * 0.42;

    final palette = [
      const Color(0xFF2563EB),
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF22C55E),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];

    // Outer rotating color segments
    final segmentCount = palette.length;
    for (int i = 0; i < segmentCount; i++) {
      final sweepAngle = (2 * pi / segmentCount) * 0.7;
      final startAngle =
          (i * 2 * pi / segmentCount) + rotateValue * 2 * pi;

      final arcPaint = Paint()
        ..color = palette[i].withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * 0.9),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Inner ring (counter-rotate)
    for (int i = 0; i < segmentCount; i++) {
      final sweepAngle = (2 * pi / segmentCount) * 0.5;
      final startAngle =
          (i * 2 * pi / segmentCount) - rotateValue * 2 * pi * 0.6;

      final arcPaint = Paint()
        ..color = palette[(i + 3) % segmentCount].withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: maxRadius * 0.6),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // Center palette icon representation — layered circles
    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * 2 * pi + pulseValue * 0.3;
      final offset = Offset(
        center.dx + cos(angle) * 18,
        center.dy + sin(angle) * 18,
      );
      canvas.drawCircle(
        offset,
        14,
        Paint()..color = palette[i].withValues(alpha: 0.8),
      );
      canvas.drawCircle(
        offset,
        14,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // Floating material swatches
    final random = Random(77);
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + dataValue * pi;
      final dist = maxRadius * (0.35 + random.nextDouble() * 0.45);
      final swatchCenter = Offset(
        center.dx + cos(angle) * dist,
        center.dy + sin(angle) * dist,
      );
      final swatchSize = 6.0 + random.nextDouble() * 6;
      final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: swatchCenter, width: swatchSize, height: swatchSize),
        const Radius.circular(2),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..color = palette[i % palette.length]
              .withValues(alpha: 0.3 + sin(dataValue * 2 * pi + i) * 0.2),
      );
    }
  }

  // ─── SLIDE 3: Preview & Buy — 3D Product Card ──────────────────────
  void _paintPreviewVisual(Canvas canvas, Size size, Offset center) {
    final maxRadius = size.width * 0.42;

    // Orbital rings
    for (int i = 0; i < 3; i++) {
      final radius = maxRadius * (0.65 + i * 0.15);
      final angle = rotateValue * 2 * pi + i * (pi / 3);

      canvas.save();
      canvas.translate(center.dx, center.dy);

      // Tilt to give 3D perspective
      final path = Path();
      for (int j = 0; j <= 60; j++) {
        final a = (j / 60) * 2 * pi + angle;
        final x = cos(a) * radius;
        final y = sin(a) * radius * (0.35 + i * 0.05);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      canvas.drawPath(
        path,
        Paint()
          ..color = primaryColor.withValues(alpha: 0.15 + i * 0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      canvas.restore();
    }

    // Central product card (simulated 3D)
    final cardW = size.width * 0.32;
    final cardH = size.height * 0.42;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: cardW, height: cardH),
      const Radius.circular(16),
    );

    // Card shadow / glow
    canvas.drawRRect(
      cardRect.shift(const Offset(0, 4)),
      Paint()
        ..color = primaryColor.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Card fill
    canvas.drawRRect(
      cardRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1f35),
            const Color(0xFF131829),
          ],
        ).createShader(cardRect.outerRect),
    );

    // Card border
    canvas.drawRRect(
      cardRect,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Product silhouette lines inside card
    final productCenter = Offset(center.dx, center.dy - cardH * 0.08);
    for (int i = 0; i < 5; i++) {
      final y = productCenter.dy - 15 + i * 10.0;
      final halfW = (cardW * 0.3) - (i - 2).abs() * 6;
      canvas.drawLine(
        Offset(productCenter.dx - halfW, y),
        Offset(productCenter.dx + halfW, y),
        Paint()
          ..color = primaryColor.withValues(alpha: 0.25)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    }

    // Price tag
    final tagCenter = Offset(center.dx, center.dy + cardH * 0.25);
    final tagRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: tagCenter, width: 56, height: 22),
      const Radius.circular(11),
    );
    canvas.drawRRect(
      tagRect,
      Paint()
        ..shader = LinearGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(tagRect.outerRect),
    );

    // Rotating highlight dot on orbit
    final orbitAngle = rotateValue * 2 * pi;
    final highlightPos = Offset(
      center.dx + cos(orbitAngle) * maxRadius * 0.75,
      center.dy + sin(orbitAngle) * maxRadius * 0.75 * 0.35,
    );
    canvas.drawCircle(
      highlightPos,
      5,
      Paint()..color = secondaryColor.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      highlightPos,
      10,
      Paint()
        ..color = secondaryColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 360° badge
    final badgeCenter = Offset(center.dx + cardW * 0.35, center.dy - cardH * 0.35);
    canvas.drawCircle(
      badgeCenter,
      14,
      Paint()
        ..shader = LinearGradient(
          colors: [primaryColor, secondaryColor],
        ).createShader(Rect.fromCircle(center: badgeCenter, radius: 14)),
    );
    canvas.drawCircle(
      badgeCenter,
      14,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────
  void _drawDashedCircle(Canvas canvas, Offset center, double radius,
      Paint paint, double startAngle, int segments) {
    final gapAngle = (2 * pi / segments) * 0.35;
    final dashAngle = (2 * pi / segments) - gapAngle;

    for (int i = 0; i < segments; i++) {
      final start = startAngle + i * (dashAngle + gapAngle);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashAngle,
        false,
        paint,
      );
    }
  }

  void _drawCornerBrackets(
      Canvas canvas, Offset center, double halfSize, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final len = halfSize * 0.25;
    final corners = [
      Offset(center.dx - halfSize, center.dy - halfSize), // TL
      Offset(center.dx + halfSize, center.dy - halfSize), // TR
      Offset(center.dx - halfSize, center.dy + halfSize), // BL
      Offset(center.dx + halfSize, center.dy + halfSize), // BR
    ];
    final dirs = [
      [const Offset(1, 0), const Offset(0, 1)],
      [const Offset(-1, 0), const Offset(0, 1)],
      [const Offset(1, 0), const Offset(0, -1)],
      [const Offset(-1, 0), const Offset(0, -1)],
    ];

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        corners[i],
        corners[i] + dirs[i][0] * len,
        paint,
      );
      canvas.drawLine(
        corners[i],
        corners[i] + dirs[i][1] * len,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VisualPainter oldDelegate) =>
      oldDelegate.rotateValue != rotateValue ||
      oldDelegate.pulseValue != pulseValue ||
      oldDelegate.dataValue != dataValue ||
      oldDelegate.slideIndex != slideIndex;
}

import 'dart:math';
import 'package:flutter/material.dart';

/// Animated mesh-gradient background that renders flowing color blobs.
/// Each slide has its own color set producing a unique, living background.
class MeshGradientBackground extends StatefulWidget {
  final List<Color> colors;
  final int slideIndex;

  const MeshGradientBackground({
    super.key,
    required this.colors,
    this.slideIndex = 0,
  });

  @override
  State<MeshGradientBackground> createState() =>
      _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MeshPainter(
            colors: widget.colors,
            animationValue: _controller.value,
            slideIndex: widget.slideIndex,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final List<Color> colors;
  final double animationValue;
  final int slideIndex;

  _MeshPainter({
    required this.colors,
    required this.animationValue,
    required this.slideIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dark base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF060A14),
    );

    final blobConfigs = _getBlobConfigs(size);

    for (int i = 0; i < blobConfigs.length; i++) {
      final blob = blobConfigs[i];
      final phase = (animationValue * 2 * pi) + (i * pi / 3);

      final dx = sin(phase + blob['phaseX']!) * blob['amplitude']!;
      final dy = cos(phase * 0.7 + blob['phaseY']!) * blob['amplitude']! * 0.8;

      final center = Offset(
        blob['cx']! + dx,
        blob['cy']! + dy,
      );

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            (colors[i % colors.length]).withValues(alpha: blob['opacity']!),
            (colors[i % colors.length]).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: blob['radius']!),
        )
        ..blendMode = BlendMode.plus;

      canvas.drawCircle(center, blob['radius']!, paint);
    }

    // Subtle noise-like overlay for depth
    final noisePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..blendMode = BlendMode.overlay;
    final random = Random(42);
    for (int i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 1.5 + 0.5,
        noisePaint,
      );
    }
  }

  List<Map<String, double>> _getBlobConfigs(Size size) {
    final w = size.width;
    final h = size.height;

    return [
      {
        'cx': w * 0.2,
        'cy': h * 0.15,
        'radius': w * 0.55,
        'opacity': 0.25,
        'amplitude': w * 0.06,
        'phaseX': 0.0,
        'phaseY': 1.2,
      },
      {
        'cx': w * 0.8,
        'cy': h * 0.3,
        'radius': w * 0.45,
        'opacity': 0.20,
        'amplitude': w * 0.05,
        'phaseX': 2.0,
        'phaseY': 0.5,
      },
      {
        'cx': w * 0.5,
        'cy': h * 0.6,
        'radius': w * 0.5,
        'opacity': 0.18,
        'amplitude': w * 0.07,
        'phaseX': 4.0,
        'phaseY': 3.0,
      },
      {
        'cx': w * 0.15,
        'cy': h * 0.75,
        'radius': w * 0.4,
        'opacity': 0.15,
        'amplitude': w * 0.04,
        'phaseX': 1.5,
        'phaseY': 2.2,
      },
      {
        'cx': w * 0.85,
        'cy': h * 0.85,
        'radius': w * 0.35,
        'opacity': 0.12,
        'amplitude': w * 0.05,
        'phaseX': 3.5,
        'phaseY': 0.8,
      },
    ];
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue ||
      oldDelegate.slideIndex != slideIndex;
}

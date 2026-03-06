import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/customization_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/robust_image_loader.dart';

import '../widgets/mesh_painter.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _autoRotate = true;
  late AnimationController _autoRotateController;
  double _manualRotationY = 0;
  double _manualRotationX = 0;
  double _scale = 1.0;
  Offset _lastFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _autoRotateController.repeat();
      } else {
        _autoRotateController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final customProvider = context.watch<CustomizationProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Product';
    final capturedImages = scanProvider.capturedImages;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/customize'),
        ),
        title: const Text('360° Preview'),
        actions: [
          IconButton(
            icon: Icon(
              _autoRotate ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: _autoRotate ? AppTheme.primaryBlue : AppTheme.textPrimary,
            ),
            onPressed: _toggleAutoRotate,
            tooltip: _autoRotate ? 'Stop Rotation' : 'Auto Rotate',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _manualRotationX = 0;
                _manualRotationY = 0;
                _scale = 1.0;
                if (!_autoRotate) _toggleAutoRotate();
              });
            },
            tooltip: 'Reset View',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingMd),

            // Main preview container
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: AspectRatio(
                aspectRatio: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.cardBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: customProvider.selectedColor
                            .withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Interactive Image Viewer
                        GestureDetector(
                          onScaleStart: (details) {
                            if (_autoRotate) {
                              _toggleAutoRotate();
                            }
                            _lastFocalPoint = details.focalPoint;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              final dx =
                                  details.focalPoint.dx - _lastFocalPoint.dx;
                              final dy =
                                  details.focalPoint.dy - _lastFocalPoint.dy;

                              _manualRotationY += dx * 0.01;
                              _manualRotationX -= dy * 0.01;

                              _manualRotationX = _manualRotationX.clamp(
                                  -math.pi / 4, math.pi / 4);

                              _scale = (_scale * details.scale).clamp(1.0, 3.0);
                              _lastFocalPoint = details.focalPoint;
                            });
                          },
                          child: Container(
                            color: Colors.black,
                            alignment: Alignment.center,
                            child: AnimatedBuilder(
                              animation: _autoRotateController,
                              builder: (context, child) {
                                final autoRotY = _autoRotate
                                    ? math.sin(_autoRotateController.value *
                                            2 *
                                            math.pi) *
                                        0.2
                                    : 0.0;
                                final autoRotX = _autoRotate
                                    ? math.cos(_autoRotateController.value *
                                            2 *
                                            math.pi) *
                                        0.05
                                    : 0.0;

                                final totalRotY = _manualRotationY + autoRotY;
                                final totalRotX = _manualRotationX + autoRotX;

                                // Choose best image
                                String? currentImage;
                                if (capturedImages.isNotEmpty) {
                                  if (capturedImages.length >= 3) {
                                    // Normalize rotation to pick image
                                    double normRotY = totalRotY;
                                    while (normRotY > math.pi) { normRotY -= 2 * math.pi; }
                                    while (normRotY < -math.pi) { normRotY -= 2 * math.pi; }

                                    if (normRotY < -0.5) {
                                      currentImage = capturedImages[0];
                                    } else if (normRotY > 0.5) {
                                      currentImage = capturedImages[2];
                                    } else {
                                      currentImage = capturedImages[1];
                                    }
                                  } else {
                                    currentImage = scanProvider.primaryImage;
                                  }
                                }

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // 3D Mesh Overlay
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: MeshPainter(
                                          rotationX: totalRotX,
                                          rotationY: totalRotY,
                                          color: customProvider.selectedColor,
                                          viewMode: MeshViewMode.solid,
                                          bodyPart: bodyPart,
                                          opacity: 0.15,
                                        ),
                                      ),
                                    ),
                                    
                                    Transform.scale(
                                      scale: _scale,
                                      child: Transform(
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.001)
                                          ..rotateX(totalRotX)
                                          ..rotateY(totalRotY * 0.5),
                                        alignment: Alignment.center,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            RobustImageLoader(
                                              imagePath: currentImage ?? scanProvider.primaryImage,
                                              iconColor: customProvider.selectedColor,
                                              fallbackLabel: '360° $bodyPart View',
                                            ),
                                            // Subtle customization glow
                                            Positioned.fill(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(boxShadow: [
                                                  BoxShadow(
                                                    color: customProvider.selectedColor
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 50,
                                                    spreadRadius: 15,
                                                  )
                                                ]),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        // Customization Overlays (Material Chip)
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: customProvider.selectedColor
                                  .withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(
                                  color: customProvider.selectedColor
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: customProvider.selectedColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  customProvider.selectedMaterial,
                                  style: TextStyle(
                                    color: customProvider.selectedColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms),

                        // Personalization Text Overlay
                        if (customProvider.personalizationText.isNotEmpty)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.cardBackground
                                    .withValues(alpha: 0.8),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                                border: Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.text_fields_rounded,
                                      color: AppTheme.textSecondary, size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '"${customProvider.personalizationText}"',
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms),

                        // Interaction hint
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.touch_app_rounded,
                                      color: AppTheme.textSecondary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    _autoRotate
                                        ? 'Tap to control view'
                                        : 'Drag to rotate · Pinch to zoom',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            // Product info
            Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: customProvider.selectedColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.settings_suggest_rounded,
                        color: AppTheme.darkBackground,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$bodyPart Support',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${customProvider.selectedMaterial} · ${customProvider.selectedPattern} · ${customProvider.selectedFitType}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${customProvider.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: AppTheme.spacingMd),

            // Continue to checkout
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: GradientButton(
                text: 'Proceed to Checkout',
                icon: Icons.shopping_cart_rounded,
                onPressed: () => context.go('/checkout'),
                height: 54,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}



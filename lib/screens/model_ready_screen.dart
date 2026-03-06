import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/robust_image_loader.dart';
import '../widgets/mesh_painter.dart';

class ModelReadyScreen extends StatefulWidget {
  const ModelReadyScreen({super.key});

  @override
  State<ModelReadyScreen> createState() => _ModelReadyScreenState();
}

class _ModelReadyScreenState extends State<ModelReadyScreen> {
  double _rotationX = 0;
  double _rotationY = 0;
  double _scale = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  MeshViewMode _viewMode = MeshViewMode.solid;

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Body Part';
    final capturedImages = scanProvider.capturedImages;
    
    // Choose the best image based on rotation angle
    String? currentImage;
    if (capturedImages.isNotEmpty) {
      if (capturedImages.length >= 3) {
        if (_rotationY < -0.5) {
          currentImage = capturedImages[0];
        } else if (_rotationY > 0.5) {
          currentImage = capturedImages[2];
        } else {
          currentImage = capturedImages[1];
        }
      } else {
        currentImage = scanProvider.primaryImage;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: Text('$bodyPart 3D Model'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _rotationX = 0;
                _rotationY = 0;
                _scale = 1.0;
                _viewMode = MeshViewMode.solid;
              });
            },
            tooltip: 'Reset View',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // View Mode Selectors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildModeTab('Texture', MeshViewMode.xray, Icons.image_rounded),
                  const SizedBox(width: 8),
                  _buildModeTab('Mesh', MeshViewMode.solid, Icons.grid_view_rounded),
                  const SizedBox(width: 8),
                  _buildModeTab('Wireframe', MeshViewMode.wireframe, Icons.polyline_rounded),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Interactive Image-Based 3D Viewer
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.cardBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl - 2),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        onScaleStart: (details) {
                          _lastFocalPoint = details.focalPoint;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            final dx = details.focalPoint.dx - _lastFocalPoint.dx;
                            final dy = details.focalPoint.dy - _lastFocalPoint.dy;

                            _rotationY += dx * 0.01;
                            _rotationX -= dy * 0.01;
                            _rotationX = _rotationX.clamp(-math.pi / 4, math.pi / 4);
                            _scale = (_scale * details.scale).clamp(1.0, 3.0);
                            _lastFocalPoint = details.focalPoint;
                          });
                        },
                        child: Container(
                          color: Colors.black,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Scanned Image with Transform (Only if in Texture/Xray - here xray represents texture overlay)
                              if (_viewMode == MeshViewMode.xray)
                                Transform.scale(
                                  scale: _scale,
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateX(_rotationX)
                                      ..rotateY(_rotationY * 0.5),
                                    alignment: Alignment.center,
                                    child: RobustImageLoader(
                                      imagePath: currentImage,
                                      fallbackLabel: '3D $bodyPart Scan\nProcessing mapping data...',
                                    ),
                                  ),
                                ),

                              // High-Fidelity 3D Mesh Overlay
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: MeshPainter(
                                    rotationX: _rotationX,
                                    rotationY: _rotationY,
                                    color: AppTheme.primaryBlue,
                                    viewMode: _viewMode,
                                    bodyPart: bodyPart,
                                    opacity: _viewMode == MeshViewMode.xray ? 0.3 : 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top labels
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                                border: Border.all(
                                    color: AppTheme.primaryBlue
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.view_in_ar_rounded,
                                      color: AppTheme.primaryBlue, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$bodyPart Scan',
                                    style: const TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.success.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusFull),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: AppTheme.success, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Processed',
                                    style: TextStyle(
                                      color: AppTheme.success,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
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
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.touch_app_rounded,
                                    color: AppTheme.textSecondary, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Drag to rotate · Pinch to zoom',
                                  style: TextStyle(
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
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                  ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            // Scan info card
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: Container(
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
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: const Icon(Icons.check_circle_rounded,
                          color: AppTheme.success, size: 24),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Scan Complete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'High accuracy mapping of $bodyPart ready',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

            const SizedBox(height: AppTheme.spacingMd),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/scan'),
                      icon: const Icon(Icons.replay_rounded,
                          color: AppTheme.textSecondary),
                      label: const Text('Rescan',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 52),
                        side: const BorderSide(color: AppTheme.cardBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    flex: 2,
                    child: GradientButton(
                      text: 'Customize',
                      icon: Icons.palette_rounded,
                      onPressed: () => context.go('/customize'),
                      height: 52,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }
  Widget _buildModeTab(String label, MeshViewMode mode, IconData icon) {
    bool isSelected = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';

class ModelReadyScreen extends StatefulWidget {
  const ModelReadyScreen({super.key});

  @override
  State<ModelReadyScreen> createState() => _ModelReadyScreenState();
}

class _ModelReadyScreenState extends State<ModelReadyScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  double _rotationX = 0.3;
  double _rotationY = 0.0;
  double _scale = 1.0;
  Offset _lastPanOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _resetView() {
    setState(() {
      _rotationX = 0.3;
      _rotationY = 0.0;
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Body Part';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/scan'),
        ),
        title: Text('$bodyPart 3D Model'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _resetView,
            tooltip: 'Reset View',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingMd),

            // 3D Model Viewer area
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  _lastPanOffset = details.focalPoint;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    final delta = details.focalPoint - _lastPanOffset;
                    _rotationY += delta.dx * 0.01;
                    _rotationX += delta.dy * 0.01;
                    _lastPanOffset = details.focalPoint;
                    _scale = (_scale * details.scale).clamp(0.5, 3.0);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLg),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotationX)
                        ..rotateY(_rotationY)
                        ..scaleByVector3(Vector3(_scale, _scale, _scale)),
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: _rotationController,
                        builder: (context, child) {
                          return _build3DModelWidget(bodyPart);
                        },
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                  ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Controls hint
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHintChip(Icons.touch_app_rounded, 'Drag to rotate'),
                  const SizedBox(width: AppTheme.spacingMd),
                  _buildHintChip(Icons.pinch_rounded, 'Pinch to zoom'),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: AppTheme.spacingLg),

            // Model info card
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Complete',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'High accuracy 3D model ready',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: const Text(
                        '90%',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

            const SizedBox(height: AppTheme.spacingLg),

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
            ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }

  Widget _build3DModelWidget(String bodyPart) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Simulated 3D wireframe model representation
        Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Wireframe rings
            for (int i = 0; i < 3; i++)
              Container(
                width: 120 + (i * 30.0),
                height: 120 + (i * 30.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryBlue
                        .withValues(alpha: 0.15 - (i * 0.04)),
                    width: 1,
                  ),
                ),
              ),
            // Body part icon
            Icon(
              _getBodyPartIcon(bodyPart),
              size: 80,
              color: AppTheme.primaryBlue.withValues(alpha: 0.8),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          bodyPart,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHintChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.textTertiary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBodyPartIcon(String bodyPart) {
    switch (bodyPart.toLowerCase()) {
      case 'hand':
        return Icons.front_hand_rounded;
      case 'knee':
        return Icons.airline_seat_legroom_extra_rounded;
      case 'ankle':
        return Icons.do_not_step_rounded;
      case 'shoulder':
        return Icons.accessibility_new_rounded;
      case 'elbow':
        return Icons.switch_access_shortcut_rounded;
      default:
        return Icons.radar_rounded;
    }
  }
}

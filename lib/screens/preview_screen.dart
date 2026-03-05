import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/customization_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _autoRotateController;
  double _rotationAngle = 0.0;
  double _rotationX = 0.2;
  double _scale = 1.0;
  String _currentView = 'Front';
  bool _autoRotate = false;
  Offset _lastPanOffset = Offset.zero;

  final Map<String, double> _viewAngles = {
    'Front': 0.0,
    'Side': 1.57,
    'Back': 3.14,
    'Top': -1.2,
  };

  @override
  void initState() {
    super.initState();
    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _autoRotateController.addListener(() {
      if (_autoRotate) {
        setState(() {
          _rotationAngle = _autoRotateController.value * 6.28;
        });
      }
    });
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

  void _setView(String view) {
    setState(() {
      _currentView = view;
      _rotationAngle = _viewAngles[view] ?? 0.0;
      _autoRotate = false;
      _autoRotateController.stop();
      if (view == 'Top') {
        _rotationX = -1.2;
      } else {
        _rotationX = 0.2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final customProvider = context.watch<CustomizationProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Product';

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
              _autoRotate ? Icons.pause_rounded : Icons.threed_rotation_rounded,
              color: _autoRotate ? AppTheme.primaryBlue : AppTheme.textPrimary,
            ),
            onPressed: _toggleAutoRotate,
            tooltip: _autoRotate ? 'Stop Rotation' : 'Auto Rotate',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 3D Preview
            Expanded(
              child: GestureDetector(
                onScaleStart: (details) {
                  _lastPanOffset = details.focalPoint;
                  if (_autoRotate) _toggleAutoRotate();
                },
                onScaleUpdate: (details) {
                  setState(() {
                    final delta = details.focalPoint - _lastPanOffset;
                    _rotationAngle += delta.dx * 0.01;
                    _rotationX += delta.dy * 0.01;
                    _lastPanOffset = details.focalPoint;
                    _scale = (_scale * details.scale).clamp(0.5, 3.0);
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(AppTheme.spacingMd),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: customProvider.selectedColor.withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotationX)
                        ..rotateY(_rotationAngle)
                        ..scaleByVector3(Vector3(_scale, _scale, _scale)),
                      alignment: Alignment.center,
                      child: _buildPreviewModel(
                        bodyPart,
                        customProvider,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 500.ms),
            ),

            // Quick view buttons
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: Row(
                children: _viewAngles.keys.map((view) {
                  final isActive = _currentView == view;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _setView(view),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.primaryBlue.withValues(alpha: 0.15)
                                : AppTheme.cardBackground,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: isActive
                                  ? AppTheme.primaryBlue
                                  : AppTheme.cardBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              view,
                              style: TextStyle(
                                color: isActive
                                    ? AppTheme.primaryBlue
                                    : AppTheme.textTertiary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

            const SizedBox(height: AppTheme.spacingMd),

            // Rotation slider
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: Row(
                children: [
                  const Text('0°',
                      style: TextStyle(
                          color: AppTheme.textTertiary, fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: (_rotationAngle % 6.28) / 6.28,
                      onChanged: (value) {
                        if (_autoRotate) _toggleAutoRotate();
                        setState(() {
                          _rotationAngle = value * 6.28;
                        });
                      },
                      activeColor: AppTheme.primaryBlue,
                      inactiveColor: AppTheme.cardBorder,
                    ),
                  ),
                  const Text('360°',
                      style: TextStyle(
                          color: AppTheme.textTertiary, fontSize: 12)),
                ],
              ),
            ),

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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: customProvider.selectedColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSm),
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
            ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

            const SizedBox(height: AppTheme.spacingMd),

            // Continue to checkout
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingLg),
              child: GradientButton(
                text: 'Proceed to Checkout',
                icon: Icons.shopping_cart_rounded,
                onPressed: () => context.go('/checkout'),
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

            const SizedBox(height: AppTheme.spacingMd),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewModel(
    String bodyPart,
    CustomizationProvider custom,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: custom.selectedColor.withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Outer ring
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: custom.selectedColor.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: custom.selectedColor.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            // Product model
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: custom.selectedColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: custom.selectedColor.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: Icon(
                _getBodyPartIcon(bodyPart),
                size: 48,
                color: custom.selectedColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        if (custom.personalizationText.isNotEmpty)
          Text(
            custom.personalizationText,
            style: TextStyle(
              color: custom.selectedColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
      ],
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

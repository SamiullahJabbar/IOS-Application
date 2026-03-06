import 'dart:async';
import 'package:camera/camera.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/scan_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/mesh_painter.dart';

class GuidedScanScreen extends StatefulWidget {
  const GuidedScanScreen({super.key});

  @override
  State<GuidedScanScreen> createState() => _GuidedScanScreenState();
}

class _GuidedScanScreenState extends State<GuidedScanScreen>
    with TickerProviderStateMixin {
  bool _scanStarted = false;
  bool _scanComplete = false;
  bool _isProcessing = false;
  double _progress = 0.0;
  Timer? _progressTimer;
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _cornersController;

  // Camera
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraPermissionDenied = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _cornersController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraError = 'No camera found on this device';
          });
        }
        return;
      }

      // Use the back camera
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('permission') ||
              e.toString().contains('Permission') ||
              e.toString().contains('CameraAccessDenied')) {
            _cameraPermissionDenied = true;
            _cameraError = 'Camera permission denied. Please enable it in Settings.';
          } else {
            _cameraError = 'Could not initialize camera: ${e.toString()}';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _scanLineController.dispose();
    _pulseController.dispose();
    _cornersController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _startScan() {
    final provider = context.read<ScanProvider>();
    provider.startScanning(); // Reset session state
    
    setState(() {
      _scanStarted = true;
      _progress = 0.0;
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          _progress += 0.02;
          if (_progress >= 1.0) {
            _progress = 1.0;
            timer.cancel();
            _processScan();
          }
        });
        context.read<ScanProvider>().updateProgress(_progress);
      }
    });
  }

  Future<void> _processScan() async {
    setState(() => _isProcessing = true);
    context.read<ScanProvider>().startProcessing();

    // Capture multiple photos to simulate 3D mapping data during processing
    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        for (int i = 0; i < 3; i++) {
          final image = await _cameraController!.takePicture();
          if (mounted) {
            context.read<ScanProvider>().addCapturedImage(image.path);
          }
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      debugPrint('Failed to capture images: $e');
    }

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    await context.read<ScanProvider>().completeScan(userId);

    setState(() {
      _isProcessing = false;
      _scanComplete = true;
    });
  }

  Widget _buildCameraPreview() {
    // Camera error / permission denied state
    if (_cameraError != null) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF1a1a2e),
              Colors.black.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _cameraPermissionDenied
                      ? Icons.no_photography_rounded
                      : Icons.error_outline_rounded,
                  color: AppTheme.primaryBlue.withValues(alpha: 0.6),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _cameraError!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                if (_cameraPermissionDenied) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _initializeCamera,
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppTheme.primaryBlue),
                    label: const Text('Retry',
                        style: TextStyle(color: AppTheme.primaryBlue)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Camera initializing state
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              const Color(0xFF1a1a2e),
              Colors.black.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppTheme.primaryBlue,
                strokeWidth: 2,
              ),
              SizedBox(height: 16),
              Text(
                'Initializing Camera...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Live camera preview
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize?.height ?? 1,
          height: _cameraController!.value.previewSize?.width ?? 1,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scanProvider = context.watch<ScanProvider>();
    final bodyPart = scanProvider.selectedBodyPart ?? 'Body Part';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () {
            _progressTimer?.cancel();
            context.go('/select-part');
          },
        ),
        title: Text('Scan $bodyPart'),
      ),
      body: Stack(
        children: [
          // Live camera background (replaces the old simulated gradient)
          Positioned.fill(
            child: _buildCameraPreview(),
          ),

          // Dark overlay for better UI contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),

          // Grid overlay
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),

          // Scanning frame
          Center(
            child: AnimatedBuilder(
              animation: _cornersController,
              builder: (context, child) {
                return Container(
                  width: 280,
                  height: 340,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.primaryBlue.withValues(
                        alpha: 0.3 + (_cornersController.value * 0.3),
                      ),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets
                      ..._buildCornerBrackets(),

                      // Scan line animation
                      if (_scanStarted && !_scanComplete && !_isProcessing)
                        AnimatedBuilder(
                          animation: _scanLineController,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanLineController.value * 320,
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                                      AppTheme.accentGlow,
                                      AppTheme.primaryBlue.withValues(alpha: 0.8),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Body part icon
                      Center(
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _scanStarted
                                  ? 0.2
                                  : 0.4 + (_pulseController.value * 0.3),
                              child: Icon(
                                _getBodyPartIcon(bodyPart),
                                size: 100,
                                color: AppTheme.primaryBlue,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Instruction text
                    if (!_scanStarted) ...[
                      _buildInstructionCard(
                        'Hold camera 20-30cm from your $bodyPart',
                        Icons.straighten_rounded,
                      ).animate().fadeIn(duration: 500.ms),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildInstructionCard(
                        'Keep steady and ensure good lighting',
                        Icons.light_mode_rounded,
                      ).animate().fadeIn(duration: 500.ms, delay: 200.ms),
                      const SizedBox(height: AppTheme.spacingLg),
                      GradientButton(
                        text: 'Start Scan',
                        icon: Icons.play_arrow_rounded,
                        onPressed: _startScan,
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),
                    ],

                    // Progress bar during scan
                    if (_scanStarted && !_scanComplete && !_isProcessing) ...[
                      Text(
                        'Scanning $bodyPart...',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: AppTheme.cardBackground,
                          valueColor: const AlwaysStoppedAnimation(
                              AppTheme.primaryBlue),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    // Processing
                    if (_isProcessing) ...[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 3D Mesh Building Animation
                            Positioned.fill(
                              child: CustomPaint(
                                painter: MeshPainter(
                                  rotationX: 0.2,
                                  rotationY: _progress * 4 * math.pi, // Spin while building
                                  color: AppTheme.primaryBlue,
                                  viewMode: _progress > 0.7 ? MeshViewMode.solid : MeshViewMode.wireframe,
                                  bodyPart: bodyPart,
                                  progress: _progress,
                                  opacity: 0.6,
                                ),
                              ),
                            ),
                            
                            if (_progress < 0.3)
                              const CircularProgressIndicator(
                                color: AppTheme.primaryBlue,
                                strokeWidth: 2,
                              ).animate().scale(duration: 400.ms),

                            Icon(
                              _progress > 0.8
                                  ? Icons.view_in_ar_rounded
                                  : Icons.grain_rounded,
                              color: AppTheme.primaryBlue,
                              size: 40,
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                             .scale(duration: 800.ms, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text(
                        'Generating 3D Mesh...',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 240,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: AppTheme.cardBackground,
                            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
                            minHeight: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _progress < 0.4 
                            ? 'Analyzing point cloud...' 
                            : _progress < 0.7 
                                ? 'Reconstructing surface geometry...' 
                                : 'Finalizing high-fidelity 3D model...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    // Scan complete
                    if (_scanComplete) ...[
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppTheme.success,
                          size: 36,
                        ),
                      ).animate().scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text(
                        '3D Model Ready!',
                        style: TextStyle(
                          color: AppTheme.success,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      GradientButton(
                        text: 'Continue to Customize',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => context.go('/model'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 30.0;
    const thickness = 3.0;
    const color = AppTheme.primaryBlue;

    return [
      // Top Left
      Positioned(
        top: 0,
        left: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, Corner.topLeft)),
        ),
      ),
      // Top Right
      Positioned(
        top: 0,
        right: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, Corner.topRight)),
        ),
      ),
      // Bottom Left
      Positioned(
        bottom: 0,
        left: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, Corner.bottomLeft)),
        ),
      ),
      // Bottom Right
      Positioned(
        bottom: 0,
        right: 0,
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CornerPainter(color, thickness, Corner.bottomRight)),
        ),
      ),
    ];
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

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Corner corner;

  _CornerPainter(this.color, this.thickness, this.corner);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (corner) {
      case Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case Corner.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryBlue.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

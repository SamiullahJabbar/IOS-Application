import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/mesh_gradient_painter.dart';
import '../widgets/onboarding_visual.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isChecking = true;

  static const _slides = [
    _SlideData(
      title: 'Scan Your\nBody Part',
      subtitle: 'LiDAR BODY SCANNING',
      description:
          'Point your iPhone at any body part — hand, knee, ankle, shoulder or elbow — and capture precise 3D measurements using LiDAR depth sensing.',
      chips: ['Hand & Wrist', 'Knee & Ankle', '3D Depth Map'],
      colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF7C3AED)],
      primaryColor: Color(0xFF3B82F6),
      secondaryColor: Color(0xFF7C3AED),
    ),
    _SlideData(
      title: 'Design Your\nPerfect Brace',
      subtitle: 'PRODUCT CUSTOMIZATION',
      description:
          'Pick premium materials like leather or carbon fiber, choose your color and pattern, and engrave your name on a support built to fit only you.',
      chips: ['Leather & Silicone', 'Custom Colors', 'Your Name'],
      colors: [Color(0xFF7C3AED), Color(0xFFEC4899), Color(0xFFA855F7)],
      primaryColor: Color(0xFFA855F7),
      secondaryColor: Color(0xFFEC4899),
    ),
    _SlideData(
      title: 'Preview & Order\nIn One Tap',
      subtitle: 'SEAMLESS CHECKOUT',
      description:
          'Rotate your custom brace in an interactive 360° viewer, verify the perfect fit, and place your order securely with Stripe — delivered to your doorstep.',
      chips: ['360° Preview', 'Perfect Fit', 'Secure Payment'],
      colors: [Color(0xFFEC4899), Color(0xFFF59E0B), Color(0xFFEF4444)],
      primaryColor: Color(0xFFF97316),
      secondaryColor: Color(0xFFF59E0B),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final hasSeenOnboarding = await AuthService.hasSeenOnboarding();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (hasSeenOnboarding && isLoggedIn) {
      context.go('/home');
    } else if (hasSeenOnboarding) {
      context.go('/login');
    }
    setState(() => _isChecking = false);
  }

  void _onSkip() {
    AuthService.setOnboardingSeen();
    context.go('/login');
  }

  void _onGetStarted() {
    AuthService.setOnboardingSeen();
    context.go('/login');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF060A14),
      body: Stack(
        children: [
          // ─── Animated Mesh Gradient Background ──────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: MeshGradientBackground(
              key: ValueKey(_currentPage),
              colors: _slides[_currentPage].colors,
              slideIndex: _currentPage,
            ),
          ),

          // ─── Content ───────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar: Step indicator + Skip
                _buildTopBar(),

                // Visual area
                Expanded(
                  flex: 50,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: OnboardingVisual(
                          slideIndex: index,
                          primaryColor: _slides[index].primaryColor,
                          secondaryColor: _slides[index].secondaryColor,
                        ),
                      );
                    },
                  ),
                ),

                // Glassmorphism bottom card + button
                _buildGlassCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLg,
        vertical: AppTheme.spacingMd,
      ),
      child: Row(
        children: [
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentPage + 1}',
                  style: TextStyle(
                    color: _slides[_currentPage].primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  ' / ${_slides.length}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / _slides.length,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(
                  _slides[_currentPage].primaryColor,
                ),
                minHeight: 4,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Skip button
          if (_currentPage < 2)
            GestureDetector(
              onTap: _onSkip,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 60),
        ],
      ),
    );
  }

  // ─── Glassmorphism Bottom Card ─────────────────────────────────────
  Widget _buildGlassCard() {
    final slide = _slides[_currentPage];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Column(
        key: ValueKey(_currentPage),
        mainAxisSize: MainAxisSize.min,
        children: [
          // Glass card with text content
          Flexible(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Subtitle badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  slide.primaryColor.withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(
                                color:
                                    slide.primaryColor.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              slide.subtitle,
                              style: TextStyle(
                                color: slide.primaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

                          const SizedBox(height: 10),

                          // Title
                          Text(
                            slide.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms, delay: 200.ms)
                              .slideX(
                                begin: 0.05,
                                end: 0,
                                duration: 400.ms,
                              ),

                          const SizedBox(height: 8),

                          // Description
                          Text(
                            slide.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.55),
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                          const SizedBox(height: 12),

                          // Feature chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: slide.chips.map((chip) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                  border: Border.all(
                                    color:
                                        Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: slide.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      chip,
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Button outside the glass card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: _currentPage == 2
                ? GradientButton(
                    text: 'Get Started',
                    onPressed: _onGetStarted,
                    icon: Icons.arrow_forward_rounded,
                  )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.15, end: 0, duration: 300.ms)
                : GradientButton(
                    text: 'Continue',
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Slide Data Model ───────────────────────────────────────────────
class _SlideData {
  final String title;
  final String subtitle;
  final String description;
  final List<String> chips;
  final List<Color> colors;
  final Color primaryColor;
  final Color secondaryColor;

  const _SlideData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.chips,
    required this.colors,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

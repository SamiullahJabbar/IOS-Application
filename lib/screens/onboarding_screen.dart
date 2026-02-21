import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isChecking = true;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      title: 'Scan Your Body',
      description:
          'iPhone LiDAR se apne body part ko millimeter accuracy ke saath scan karo',
      icon: Icons.view_in_ar_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF2563EB), Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingSlide(
      title: 'Customize Everything',
      description:
          'Apni marzi ka color, material aur design choose karo — sirf apne liye',
      icon: Icons.palette_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    OnboardingSlide(
      title: 'Preview & Buy',
      description:
          '360 degree mein dekho aur ek tap mein order karo — perfectly fitting product',
      icon: Icons.shopping_bag_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF59E0B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
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
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: _currentPage < 2
                    ? TextButton(
                        onPressed: _onSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : const SizedBox(height: 48),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index], index);
                },
              ),
            ),

            // Dot Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.spacingLg,
              ),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: const ExpandingDotsEffect(
                  dotColor: AppTheme.cardBorder,
                  activeDotColor: AppTheme.primaryBlue,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                  spacing: 6,
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                0,
                AppTheme.spacingLg,
                AppTheme.spacingXl,
              ),
              child: _currentPage == 2
                  ? GradientButton(
                      text: 'Get Started',
                      onPressed: _onGetStarted,
                      icon: Icons.arrow_forward_rounded,
                    ).animate().fadeIn(duration: 300.ms).slideY(
                        begin: 0.2,
                        end: 0,
                        duration: 300.ms,
                      )
                  : GradientButton(
                      text: 'Next',
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: slide.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              slide.icon,
              size: 80,
              color: Colors.white,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 200.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),

          const SizedBox(height: AppTheme.spacingXxl),

          // Title
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms),

          const SizedBox(height: AppTheme.spacingMd),

          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 600.ms, delay: 600.ms)
              .slideY(begin: 0.3, end: 0, duration: 600.ms),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

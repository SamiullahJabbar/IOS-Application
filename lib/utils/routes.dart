import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/body_part_selection_screen.dart';
import '../screens/guided_scan_screen.dart';
import '../screens/model_ready_screen.dart';
import '../screens/customization_screen.dart';
import '../screens/preview_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/order_confirmation_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const _SplashRedirect(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/select-part',
          builder: (context, state) => const BodyPartSelectionScreen(),
        ),
        GoRoute(
          path: '/scan',
          builder: (context, state) => const GuidedScanScreen(),
        ),
        GoRoute(
          path: '/model',
          builder: (context, state) => const ModelReadyScreen(),
        ),
        GoRoute(
          path: '/customize',
          builder: (context, state) => const CustomizationScreen(),
        ),
        GoRoute(
          path: '/preview',
          builder: (context, state) => const PreviewScreen(),
        ),
        GoRoute(
          path: '/checkout',
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: '/success',
          builder: (context, state) => const OrderConfirmationScreen(),
        ),
      ],
    );
  }
}

/// Splash widget that checks login state and redirects accordingly
class _SplashRedirect extends StatefulWidget {
  const _SplashRedirect();

  @override
  State<_SplashRedirect> createState() => _SplashRedirectState();
}

class _SplashRedirectState extends State<_SplashRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final hasSeenOnboarding = await AuthService.hasSeenOnboarding();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!mounted) return;

    if (!hasSeenOnboarding) {
      context.go('/onboarding');
    } else if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF060A14),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
      ),
    );
  }
}

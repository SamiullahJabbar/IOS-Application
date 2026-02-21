import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _showForgotPassword = false;
  final _resetEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Login failed'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    }
  }

  Future<void> _handlePasswordReset() async {
    if (_resetEmailController.text.isEmpty || _newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter valid email and new password (min 6 chars)'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      email: _resetEmailController.text.trim(),
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _showForgotPassword = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password reset successful! Please login.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Reset failed'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingXxl),

              // Logo / Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.view_in_ar_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                  ),

              const SizedBox(height: AppTheme.spacingXl),

              // Title
              Center(
                child: Text(
                  _showForgotPassword ? 'Reset Password' : 'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

              const SizedBox(height: AppTheme.spacingSm),

              Center(
                child: Text(
                  _showForgotPassword
                      ? 'Enter your email and new password'
                      : 'Sign in to continue your journey',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

              const SizedBox(height: AppTheme.spacingXxl),

              if (_showForgotPassword) ...[
                // Forgot Password Form
                CustomTextField(
                  controller: _resetEmailController,
                  label: 'Email Address',
                  hint: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: AppTheme.spacingMd),
                CustomTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'Minimum 6 characters',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: AppTheme.spacingLg),

                Consumer<AuthProvider>(
                  builder: (context, auth, _) => GradientButton(
                    text: 'Reset Password',
                    onPressed: _handlePasswordReset,
                    isLoading: auth.isLoading,
                    icon: Icons.lock_reset_rounded,
                  ),
                ),

                const SizedBox(height: AppTheme.spacingMd),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _showForgotPassword = false),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(color: AppTheme.primaryBlue),
                    ),
                  ),
                ),
              ] else ...[
                // Login Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'your@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                      const SizedBox(height: AppTheme.spacingMd),

                      CustomTextField(
                        controller: _passwordController,
                        label: 'Password',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: !_showPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppTheme.textTertiary,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                      const SizedBox(height: AppTheme.spacingSm),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            setState(() => _showForgotPassword = true);
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingLg),

                      // Login Button
                      Consumer<AuthProvider>(
                        builder: (context, auth, _) => GradientButton(
                          text: 'Sign In',
                          onPressed: _handleLogin,
                          isLoading: auth.isLoading,
                          icon: Icons.login_rounded,
                        ),
                      ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXl),

                // Register Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

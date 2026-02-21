import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Please login.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        ),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
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
              const SizedBox(height: AppTheme.spacingLg),

              // Back Button
              IconButton(
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: AppTheme.textPrimary),
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // Title
              Text(
                'Create Account',
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: AppTheme.spacingSm),

              Text(
                'Fill in the details to register your account',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(duration: 500.ms, delay: 100.ms),

              const SizedBox(height: AppTheme.spacingXl),

              // Register Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

                    const SizedBox(height: AppTheme.spacingMd),

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
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms),

                    const SizedBox(height: AppTheme.spacingMd),

                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Minimum 6 characters',
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms),

                    const SizedBox(height: AppTheme.spacingMd),

                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: !_showConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showConfirmPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppTheme.textTertiary,
                        ),
                        onPressed: () {
                          setState(
                              () => _showConfirmPassword = !_showConfirmPassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 500.ms),

                    const SizedBox(height: AppTheme.spacingXl),

                    // Register Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => GradientButton(
                        text: 'Create Account',
                        onPressed: _handleRegister,
                        isLoading: auth.isLoading,
                        icon: Icons.person_add_rounded,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.spacingXl),

              // Login Link
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Sign In',
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
          ),
        ),
      ),
    );
  }
}

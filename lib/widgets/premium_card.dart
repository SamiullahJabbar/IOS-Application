import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isSelected;
  final Gradient? gradient;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          gradient: gradient ?? AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class RobustImageLoader extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? iconColor;
  final String fallbackLabel;
  final int? index; // Optional index to pick from a list of images

  const RobustImageLoader({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.iconColor,
    this.fallbackLabel = '3D Scan Preview',
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    // If an index is provided and we have access to context,
    // we could try to get that specific image from ScanProvider.
    // However, for simplicity and to keep the widget generic,
    // we'll expect the specific path to be passed in.

    if (imagePath == null || imagePath!.isEmpty) {
      return _buildFallback();
    }

    try {
      if (kIsWeb) {
        // On Web, use Image.network for blob URLs or regular URLs
        return Image.network(
          imagePath!,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else {
        // On Native (Android/iOS), use Image.file
        return Image.file(
          File(imagePath!),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    } catch (e) {
      return _buildFallback();
    }
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.black.withValues(alpha: 0.2),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.blur_on_rounded,
              color: iconColor ?? AppTheme.primaryBlue.withValues(alpha: 0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              fallbackLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

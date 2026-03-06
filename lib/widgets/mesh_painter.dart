import 'dart:math' as math;
import 'package:flutter/material.dart';

enum MeshViewMode { solid, wireframe, xray }

class MeshPainter extends CustomPainter {
  final double rotationX;
  final double rotationY;
  final Color color;
  final double opacity;
  final MeshViewMode viewMode;
  final String? bodyPart;
  final double progress; // For "building" animation

  MeshPainter({
    required this.rotationX,
    required this.rotationY,
    required this.color,
    this.opacity = 1.0,
    this.viewMode = MeshViewMode.solid,
    this.bodyPart,
    this.progress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    const rows = 18; // Increased density
    const cols = 18;
    
    // Light source vector (from top-right-front)
    final lightDir = [0.5, -0.5, 1.0];
    final length = math.sqrt(lightDir[0]*lightDir[0] + lightDir[1]*lightDir[1] + lightDir[2]*lightDir[2]);
    lightDir[0] /= length;
    lightDir[1] /= length;
    lightDir[2] /= length;

    final points = List.generate(rows + 1, (r) {
      return List.generate(cols + 1, (c) {
        // Spherical/Cylindrical mapping for the mesh
        double lon = (c / cols) * 2 * math.pi;
        double lat = (r / rows) * math.pi - math.pi / 2;
        
        // Base 3D coordinates
        // Shape adaptation based on body part
        double radiusMultiplier = 1.0;
        if (bodyPart?.toLowerCase().contains('hand') ?? false) {
           // Make it wider at the base (wrist) and tapered/boxy for the palm area
           radiusMultiplier = 0.8 + 0.4 * math.sin(lat + 1.0);
        } else if (bodyPart?.toLowerCase().contains('leg') ?? false) {
           radiusMultiplier = 1.1 - 0.3 * (r / rows); // Taper down for legs
        }
        
        double x = math.cos(lat) * math.cos(lon) * radiusMultiplier;
        double y = math.sin(lat) * 1.5; 
        double z = math.cos(lat) * math.sin(lon) * radiusMultiplier;
        
        // Apply rotation
        // Y rotation
        double x1 = x * math.cos(rotationY) + z * math.sin(rotationY);
        double z1 = -x * math.sin(rotationY) + z * math.cos(rotationY);
        
        // X rotation
        double y2 = y * math.cos(rotationX) - z1 * math.sin(rotationX);
        double z2 = y * math.sin(rotationX) + z1 * math.cos(rotationX);
        
        // Project to 2D
        double p = 1.0 / (3.0 + z2); // Adjust perspective Depth
        return {
          'pos': Offset(
            centerX + x1 * p * size.width * 1.2,
            centerY + y2 * p * size.height * 1.2,
          ),
          'z': z2,
          'norm': [x, y/1.5, z], // Original normals for shading
        };
      });
    });

    // Draw faces (sorted by Z depth for simple painter's algorithm)
    List<Map<String, dynamic>> faces = [];
    final visibleRows = (rows * progress).toInt();

    for (int r = 0; r < visibleRows; r++) {
      for (int c = 0; c < cols; c++) {
        final p1 = points[r][c];
        final p2 = points[r][c + 1];
        final p3 = points[r + 1][c + 1];
        final p4 = points[r + 1][c];
        
        double avgZ = ((p1['z'] as double) + (p2['z'] as double) + (p3['z'] as double) + (p4['z'] as double)) / 4.0;
        
        // Back-face culling (simplified: only draw front faces for solid mode)
        if (viewMode == MeshViewMode.solid && avgZ > 0) continue;

        faces.add({
          'points': [p1['pos'], p2['pos'], p3['pos'], p4['pos']],
          'z': avgZ,
          'norm': p1['norm'], // Use first vertex normal for the face shading
        });
      }
    }

    // Sort by Z (back to front)
    faces.sort((a, b) => b['z'].compareTo(a['z']));

    for (final face in faces) {
      final List<Offset> poly = face['points'];
      final norm = face['norm'];
      
      // Calculate shading
      // Rotate normal based on current rotation to match light source
      double nx = norm[0] * math.cos(rotationY) + norm[2] * math.sin(rotationY);
      double nz = -norm[0] * math.sin(rotationY) + norm[2] * math.cos(rotationY);
      double ny = norm[1] * math.cos(rotationX) - nz * math.sin(rotationX);
      double finalNz = norm[1] * math.sin(rotationX) + nz * math.cos(rotationX);

      // Dot product with light
      double dot = (nx * lightDir[0] + ny * lightDir[1] + finalNz * lightDir[2]);
      double intensity = math.max(0.2, dot); // Ambient light = 0.2

      final facePath = Path()..addPolygon(poly, true);

      if (viewMode == MeshViewMode.solid) {
        final facePaint = Paint()
          ..color = Color.lerp(Colors.black, color, intensity)!
              .withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
        canvas.drawPath(facePath, facePaint);
        
        // Draw thin wireframe on top for detail
        final edgePaint = Paint()
          ..color = color.withValues(alpha: opacity * 0.3)
          ..strokeWidth = 0.3
          ..style = PaintingStyle.stroke;
        canvas.drawPath(facePath, edgePaint);
      } else if (viewMode == MeshViewMode.wireframe) {
        final edgePaint = Paint()
          ..color = color.withValues(alpha: opacity * (face['z'] < 0 ? 0.8 : 0.2))
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;
        canvas.drawPath(facePath, edgePaint);
      } else if (viewMode == MeshViewMode.xray) {
        final xrayPaint = Paint()
          ..color = color.withValues(alpha: opacity * 0.1)
          ..style = PaintingStyle.fill;
        canvas.drawPath(facePath, xrayPaint);
        
        final edgePaint = Paint()
          ..color = color.withValues(alpha: opacity * 0.4)
          ..strokeWidth = 0.4
          ..style = PaintingStyle.stroke;
        canvas.drawPath(facePath, edgePaint);
      }
    }

    // Special building markers if progress < 1
    if (progress < 1.0) {
      final markerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (int c = 0; c <= cols; c += 2) {
        if (visibleRows <= rows) {
          canvas.drawCircle(points[visibleRows][c]['pos'] as Offset, 2.0, markerPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MeshPainter oldDelegate) {
    return oldDelegate.rotationX != rotationX || 
           oldDelegate.rotationY != rotationY || 
           oldDelegate.color != color ||
           oldDelegate.viewMode != viewMode ||
           oldDelegate.progress != progress;
  }
}

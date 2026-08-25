import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';

/// Visual state of the [HandGuideFrame].
enum HandGuideState { idle, detected }

/// Dashed guide frame drawn over the camera preview.
///
/// Uses the camera tokens for its colors and switches between an idle
/// and a detected accent. Purely visual: no camera or detection logic.
class HandGuideFrame extends StatelessWidget {
  const HandGuideFrame({
    super.key,
    this.state = HandGuideState.idle,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
    this.cornerRadius = AppRadius.extraLarge,
    this.strokeWidth = 2.5,
    this.dashLength = 10,
    this.gapLength = 8,
  });

  final HandGuideState state;
  final EdgeInsets padding;
  final double cornerRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  Widget build(BuildContext context) {
    final Color color = state == HandGuideState.detected
        ? AppCameraColors.guideDetected
        : AppCameraColors.guideIdle;

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _DashedRRectPainter(
          color: color,
          padding: padding,
          cornerRadius: cornerRadius,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          gapLength: gapLength,
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({
    required this.color,
    required this.padding,
    required this.cornerRadius,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final EdgeInsets padding;
  final double cornerRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outer = Offset.zero & size;
    final Rect inset = padding.deflateRect(outer);
    final double safeRadius =
        cornerRadius.clamp(0.0, math.min(inset.width, inset.height) / 2);
    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        inset,
        Radius.circular(safeRadius),
      ));

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.padding != padding ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.gapLength != gapLength;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_spacing.dart';

/// Visual state of the [HandGuideFrame].
enum HandGuideState { idle, detected }

/// Luxury HUD Scanner Frame for the camera view.
/// Features high-tech corner brackets, gentle pulsing glow on detection,
/// and a refined center reticle.
class HandGuideFrame extends StatefulWidget {
  const HandGuideFrame({
    super.key,
    this.state = HandGuideState.idle,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
    this.cornerLength = 36,
    this.strokeWidth = 3.5,
  });

  final HandGuideState state;
  final EdgeInsets padding;
  final double cornerLength;
  final double strokeWidth;

  @override
  State<HandGuideFrame> createState() => _HandGuideFrameState();
}

class _HandGuideFrameState extends State<HandGuideFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDetected = widget.state == HandGuideState.detected;
    final Color baseColor = isDetected
        ? AppCameraColors.guideDetected
        : AppCameraColors.guideIdle;

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          final double pulse = _pulseController.value;
          return CustomPaint(
            size: Size.infinite,
            painter: _CornerScannerPainter(
              color: baseColor,
              pulse: pulse,
              isDetected: isDetected,
              padding: widget.padding,
              cornerLength: widget.cornerLength,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _CornerScannerPainter extends CustomPainter {
  const _CornerScannerPainter({
    required this.color,
    required this.pulse,
    required this.isDetected,
    required this.padding,
    required this.cornerLength,
    required this.strokeWidth,
  });

  final Color color;
  final double pulse;
  final bool isDetected;
  final EdgeInsets padding;
  final double cornerLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect outer = Offset.zero & size;
    final Rect rect = padding.deflateRect(outer);
    final double l = math.min(cornerLength, math.min(rect.width, rect.height) / 3);

    // Glow shadow if detected
    if (isDetected) {
      final Paint glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4 + (pulse * 3)
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.25 + (pulse * 0.2));

      _drawCorners(canvas, rect, l, glowPaint);
    }

    final Paint cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = isDetected ? color : color.withValues(alpha: 0.5 + (pulse * 0.3));

    _drawCorners(canvas, rect, l, cornerPaint);

    // Center subtle reticle crosshair
    final double cx = rect.center.dx;
    final double cy = rect.center.dy;
    final Paint centerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = (isDetected ? color : Colors.white).withValues(alpha: 0.25);

    const double crossSize = 10;
    canvas.drawLine(Offset(cx - crossSize, cy), Offset(cx + crossSize, cy), centerPaint);
    canvas.drawLine(Offset(cx, cy - crossSize), Offset(cx, cy + crossSize), centerPaint);
  }

  void _drawCorners(Canvas canvas, Rect rect, double l, Paint paint) {
    const double r = 16; // corner curve radius

    // Top-Left
    final Path tl = Path()
      ..moveTo(rect.left, rect.top + l)
      ..lineTo(rect.left, rect.top + r)
      ..arcToPoint(Offset(rect.left + r, rect.top), radius: const Radius.circular(r))
      ..lineTo(rect.left + l, rect.top);
    canvas.drawPath(tl, paint);

    // Top-Right
    final Path tr = Path()
      ..moveTo(rect.right - l, rect.top)
      ..lineTo(rect.right - r, rect.top)
      ..arcToPoint(Offset(rect.right, rect.top + r), radius: const Radius.circular(r))
      ..lineTo(rect.right, rect.top + l);
    canvas.drawPath(tr, paint);

    // Bottom-Left
    final Path bl = Path()
      ..moveTo(rect.left, rect.bottom - l)
      ..lineTo(rect.left, rect.bottom - r)
      ..arcToPoint(Offset(rect.left + r, rect.bottom), radius: const Radius.circular(r))
      ..lineTo(rect.left + l, rect.bottom);
    canvas.drawPath(bl, paint);

    // Bottom-Right
    final Path br = Path()
      ..moveTo(rect.right - l, rect.bottom)
      ..lineTo(rect.right - r, rect.bottom)
      ..arcToPoint(Offset(rect.right, rect.bottom - r), radius: const Radius.circular(r))
      ..lineTo(rect.right, rect.bottom - l);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerScannerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isDetected != isDetected;
  }
}

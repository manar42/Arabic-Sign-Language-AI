import 'package:flutter/material.dart';

import '../app_colors.dart';

/// Canonical 21-point hand topology (MediaPipe Hands connections),
/// expressed as presentation data only.
const List<(int, int)> kDefaultHandConnections = <(int, int)>[
  // Thumb
  (0, 1), (1, 2), (2, 3), (3, 4),
  // Index
  (0, 5), (5, 6), (6, 7), (7, 8),
  // Middle
  (5, 9), (9, 10), (10, 11), (11, 12),
  // Ring
  (9, 13), (13, 14), (14, 15), (15, 16),
  // Pinky + palm base
  (13, 17), (17, 18), (18, 19), (19, 20), (0, 17),
];

/// Visual overlay for hand landmarks.
///
/// Accepts already-extracted landmark points in normalized 0..1
/// coordinates and paints up to 21 points with their connections using
/// the camera tokens. Presentation only:
/// it never calls MediaPipe and never processes camera frames.
///
/// Set [mirrorX] when drawing over a mirrored front-camera preview so
/// the overlay aligns with what the user sees.
class LandmarkOverlay extends StatelessWidget {
  const LandmarkOverlay({
    super.key,
    this.points = const <Offset>[],
    this.mirrorX = false,
    this.connections = kDefaultHandConnections,
    this.pointColor = AppCameraColors.landmarkPoint,
    this.lineColor = AppCameraColors.landmarkLine,
    this.pointRadius = 3.5,
    this.strokeWidth = 2,
  });

  /// Normalized landmark coordinates (0..1), e.g. 21 hand points.
  final List<Offset> points;
  final bool mirrorX;
  final List<(int, int)> connections;
  final Color pointColor;
  final Color lineColor;
  final double pointRadius;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _HandPainter(
          points: points,
          mirrorX: mirrorX,
          connections: connections,
          pointColor: pointColor,
          lineColor: lineColor,
          pointRadius: pointRadius,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _HandPainter extends CustomPainter {
  const _HandPainter({
    required this.points,
    required this.mirrorX,
    required this.connections,
    required this.pointColor,
    required this.lineColor,
    required this.pointRadius,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final bool mirrorX;
  final List<(int, int)> connections;
  final Color pointColor;
  final Color lineColor;
  final double pointRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    Offset? map(int index) {
      if (index < 0 || index >= points.length) return null;
      final double dx = points[index].dx * size.width;
      final double dy = points[index].dy * size.height;
      return Offset(mirrorX ? size.width - dx : dx, dy);
    }

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = lineColor;

    for (final (int a, int b) in connections) {
      final Offset? pa = map(a);
      final Offset? pb = map(b);
      if (pa != null && pb != null) {
        canvas.drawLine(pa, pb, linePaint);
      }
    }

    final Paint pointPaint = Paint()..color = pointColor;
    for (int i = 0; i < points.length; i++) {
      final Offset? p = map(i);
      if (p != null) {
        canvas.drawCircle(p, pointRadius, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HandPainter oldDelegate) {
    return !identical(oldDelegate.points, points) ||
        oldDelegate.mirrorX != mirrorX ||
        !identical(oldDelegate.connections, connections) ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointRadius != pointRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

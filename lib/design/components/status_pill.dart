import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Presentation-oriented states for [StatusPill].
enum StatusPillState { searching, detected, holding, ready, error }

/// Compact luxury stadium pill for camera/status overlays.
/// Features frosted glass backdrop, glowing status dot, and sharp typography.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.state,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.accentColor,
  });

  final StatusPillState state;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? accentColor;

  Color _defaultAccent() => switch (state) {
        StatusPillState.searching => AppCameraColors.guideIdle,
        StatusPillState.detected => AppCameraColors.guideDetected,
        StatusPillState.holding => const Color(0xFFF59E0B),
        StatusPillState.ready => const Color(0xFF10B981),
        StatusPillState.error => const Color(0xFFEF4444),
      };

  IconData _defaultIcon() => switch (state) {
        StatusPillState.searching => Icons.lens_blur_rounded,
        StatusPillState.detected => Icons.check_circle_rounded,
        StatusPillState.holding => Icons.pan_tool_rounded,
        StatusPillState.ready => Icons.verified_rounded,
        StatusPillState.error => Icons.error_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final Color background =
        backgroundColor ?? const Color(0xDD0B0F17);
    final Color foreground = foregroundColor ?? Colors.white;
    final Color accent = accentColor ?? _defaultAccent();

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.brStadium,
        border: Border.all(
          color: accent.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 8,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon ?? _defaultIcon(), size: 16, color: accent),
          const SizedBox(width: AppSpacing.s),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelL.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

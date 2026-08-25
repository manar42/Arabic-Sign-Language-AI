import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Presentation-oriented states for [StatusPill].
enum StatusPillState { searching, detected, holding, ready, error }

/// Compact stadium pill for camera/status overlays.
///
/// Defaults come from the camera tokens so the pill stays legible on a
/// live camera feed in both themes. Purely presentational: it never owns
/// detection logic.
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

  /// Optional icon override; otherwise derived from [state].
  final IconData? icon;

  /// All colors are optional overrides; defaults use the camera tokens.
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? accentColor;

  Color _defaultAccent() => switch (state) {
        StatusPillState.searching => AppCameraColors.guideIdle,
        StatusPillState.detected => AppCameraColors.guideDetected,
        // The holding/ready/error accents reuse the dark-palette tokens
        // because they stay readable on the dark translucent pill over
        // any camera feed.
        StatusPillState.holding => AppColorsDark().warning,
        StatusPillState.ready => AppColorsDark().primary,
        StatusPillState.error => AppColorsDark().error,
      };

  IconData _defaultIcon() => switch (state) {
        StatusPillState.searching => Icons.search,
        StatusPillState.detected => Icons.check,
        StatusPillState.holding => Icons.pan_tool,
        StatusPillState.ready => Icons.check_circle,
        StatusPillState.error => Icons.error_outline,
      };

  @override
  Widget build(BuildContext context) {
    final Color background =
        backgroundColor ?? AppCameraColors.statusPillBackground;
    // White foreground is intentional here: the pill floats on the live
    // camera feed (dark scrim) regardless of app theme.
    final Color foreground = foregroundColor ?? Colors.white;
    final Color accent = accentColor ?? _defaultAccent();

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.brStadium,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
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
              style: AppTextStyles.labelL.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

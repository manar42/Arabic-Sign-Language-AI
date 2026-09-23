import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Rounded image stage for sign playback visuals.
/// Features a luxury frosted frame, deep ambient drop shadow,
/// and smooth content transitions.
class PlaybackStage extends StatelessWidget {
  const PlaybackStage({
    super.key,
    this.image,
    this.child,
    this.isLoading = false,
    this.errorMessage,
    this.semanticLabel,
    this.borderRadius = AppRadius.brExtraLarge,
  });

  final ImageProvider? image;
  final Widget? child;
  final bool isLoading;
  final String? errorMessage;
  final String? semanticLabel;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color stageText = AppColors.light.textSecondary;

    Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: scheme.primary,
          ),
        ),
      );
    } else if (errorMessage != null) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 32, color: stageText),
              const SizedBox(height: AppSpacing.s),
              Flexible(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM.copyWith(color: stageText),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (image != null) {
      content = Image(
        image: image!,
        fit: BoxFit.contain,
        semanticLabel: semanticLabel,
      );
    } else if (child != null) {
      content = child!;
    } else {
      content = const SizedBox.shrink();
    }

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}

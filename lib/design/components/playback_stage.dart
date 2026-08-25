import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Rounded image stage for sign playback visuals.
///
/// Responsive by construction: fills the parent width and keeps a
/// ~4:5 aspect ratio. Images always use BoxFit.contain. Loading and
/// error placeholders are built in; no playback logic lives here.
class PlaybackStage extends StatelessWidget {
  const PlaybackStage({
    super.key,
    this.image,
    this.child,
    this.isLoading = false,
    this.errorMessage,
    this.semanticLabel,
    this.borderRadius = AppRadius.brLarge,
  });

  /// Image to present; rendered with BoxFit.contain.
  final ImageProvider? image;

  /// Escape hatch for fully custom stage content (used when neither
  /// loading nor error applies).
  final Widget? child;

  final bool isLoading;

  /// When set (and not loading) an inline error placeholder is shown.
  final String? errorMessage;
  final String? semanticLabel;
  final BorderRadiusGeometry borderRadius;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // The image stage is intentionally LIGHT in both themes: the sign
    // images are photographic assets with inconsistent backgrounds, so
    // they need a stable light surface (approved design exception).
    final Color stageText = AppColors.light.textSecondary;

    Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.light.primary,
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
              Icon(Icons.error_outline, size: 28, color: stageText),
              const SizedBox(height: AppSpacing.s),
              Flexible(
                child: Text(
                  errorMessage!,
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.bodyM.copyWith(color: stageText),
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
          // Forced-light stage surface; the outline stays adaptive so
          // the light stage remains framed against the dark background.
          color: AppColors.light.surfaceVariant,
          borderRadius: borderRadius,
          border: Border.all(color: scheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
    );
  }
}

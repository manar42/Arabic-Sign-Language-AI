import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_shadows.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Visual tile presenting the currently detected Arabic letter.
///
/// ~96dp square using the display typography token. [confidence] is a
/// presentation parameter only (0..1) rendered as a thin indicator;
/// this widget never calculates confidence itself.
class ResultLetterTile extends StatelessWidget {
  const ResultLetterTile({
    super.key,
    required this.letter,
    this.accent,
    this.confidence,
    this.size = 96,
    this.semanticLabel,
  });

  final String letter;

  /// Optional primary accent; defaults to the theme primary.
  final Color? accent;

  /// Presentation-only value in 0..1 (clamped); shown as a small bar.
  final double? confidence;

  /// Edge length of the square tile.
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Color accentColor = accent ?? scheme.primary;

    final Widget tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppRadius.brLarge,
        border: Border.all(color: scheme.outline),
        boxShadow: AppShadows.e2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s),
        child: Column(
          children: [
            Expanded(
              child: Center(
                // FittedBox keeps the glyph inside the tile even at
                // large accessibility text scales.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    letter,
                    style: AppTextStyles.displayL
                        .copyWith(color: accent ?? scheme.onSurface),
                  ),
                ),
              ),
            ),
            if (confidence != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.stadium),
                child: LinearProgressIndicator(
                  value: confidence!.clamp(0.0, 1.0),
                  minHeight: 4,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: accentColor,
                ),
              ),
          ],
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: tile,
      );
    }
    return tile;
  }
}

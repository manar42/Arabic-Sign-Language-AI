import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';

/// Segmented progress visualization (e.g. letters of a sentence).
///
/// Responsive: every segment is expanded equally so long sequences
/// never overflow horizontally. Segments at or before [currentIndex]
/// read as filled; the active segment is slightly taller for a
/// non-color cue.
class SegmentedProgressBar extends StatelessWidget {
  const SegmentedProgressBar({
    super.key,
    required this.segmentCount,
    this.currentIndex = 0,
    this.height = 4,
    this.spacing = AppSpacing.xs,
    this.filledColor,
    this.upcomingColor,
    this.semanticLabel,
  }) : assert(segmentCount > 0);

  final int segmentCount;

  /// Index of the active segment; values are clamped. Use `-1` for
  /// "nothing started yet".
  final int currentIndex;
  final double height;
  final double spacing;

  /// Defaults to the theme primary / outline tokens.
  final Color? filledColor;
  final Color? upcomingColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int current =
        currentIndex.clamp(-1, segmentCount - 1);
    final Color filled = filledColor ?? scheme.primary;
    final Color upcoming = upcomingColor ?? scheme.outline;

    final Widget bar = SizedBox(
      height: height + 2,
      child: Row(
        children: [
          for (int i = 0; i < segmentCount; i++)
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: i == 0 ? 0 : spacing,
                ),
                child: Container(
                  height: i == current ? height + 2 : height,
                  decoration: BoxDecoration(
                    color: i <= current && current >= 0 ? filled : upcoming,
                    borderRadius:
                        BorderRadius.circular(AppRadius.stadium),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Semantics(
      label: semanticLabel ?? '${currentIndex + 1} / $segmentCount',
      child: bar,
    );
  }
}

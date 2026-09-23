import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Visual tile presenting the currently detected Arabic letter.
/// Features glassmorphic backing, confidence indicator, and an animated
/// hold-to-capture progress ring for Hands-Free mode.
class ResultLetterTile extends StatelessWidget {
  const ResultLetterTile({
    super.key,
    required this.letter,
    this.accent,
    this.confidence,
    this.holdProgress = 0.0,
    this.isCaptured = false,
    this.size = 104,
    this.semanticLabel,
  });

  final String letter;
  final Color? accent;
  final double? confidence;

  /// Progress of holding the gesture (0.0 to 1.0) before auto-capture
  final double holdProgress;

  /// Triggered briefly upon auto-capture for celebratory green glow
  final bool isCaptured;

  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color accentColor = isCaptured
        ? const Color(0xFF10B981)
        : (accent ?? scheme.primary);
    final double conf = (confidence ?? 0.0).clamp(0.0, 1.0);
    final double hold = holdProgress.clamp(0.0, 1.0);

    final Widget tile = Stack(
      alignment: Alignment.center,
      children: [
        // Outer animated progress border for Hands-Free hold
        if (hold > 0.0 && letter.isNotEmpty)
          SizedBox(
            width: size + 6,
            height: size + 6,
            child: CircularProgressIndicator(
              value: hold,
              strokeWidth: 3,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCaptured ? const Color(0xFF10B981) : const Color(0xFF14B8A6),
              ),
            ),
          ),

        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151C28) : Colors.white,
            borderRadius: AppRadius.brLarge,
            border: Border.all(
              color: isCaptured
                  ? const Color(0xFF10B981)
                  : (letter.isNotEmpty
                      ? accentColor.withValues(alpha: 0.6)
                      : scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6)),
              width: (letter.isNotEmpty || isCaptured) ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isCaptured
                    ? const Color(0xFF10B981).withValues(alpha: 0.5)
                    : (letter.isNotEmpty
                        ? accentColor.withValues(alpha: isDark ? 0.3 : 0.15)
                        : Colors.black.withValues(alpha: isDark ? 0.3 : 0.06)),
                blurRadius: isCaptured ? 24 : (letter.isNotEmpty ? 18 : 10),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: AppSpacing.s,
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        letter.isEmpty ? '—' : letter,
                        style: AppTextStyles.displayL.copyWith(
                          color: isCaptured
                              ? const Color(0xFF10B981)
                              : (letter.isEmpty
                                  ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
                                  : (accent ?? scheme.onSurface)),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                if (confidence != null && letter.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(conf * 100).toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        if (hold > 0.0)
                          Text(
                            '⚡ ${(hold * 100).toInt()}%',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF14B8A6),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.stadium),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      tween: Tween<double>(begin: 0, end: conf),
                      builder: (context, val, _) {
                        return LinearProgressIndicator(
                          value: val,
                          minHeight: 4,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : scheme.surfaceContainerHighest,
                          color: accentColor,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
              ],
            ),
          ),
        ),
      ],
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

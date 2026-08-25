import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';

/// RTL-safe chip representing a single Arabic letter.
///
/// Supports selection styling and an optional remove affordance while
/// keeping a 48dp minimum touch target. Presentation only.
class LetterChip extends StatelessWidget {
  const LetterChip({
    super.key,
    required this.letter,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.deleteSemanticLabel,
    this.semanticLabel,
  });

  final String letter;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  /// Localized screen-reader description for the remove affordance;
  /// required alongside [onDeleted] so the control is never silent.
  final String? deleteSemanticLabel;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Color background =
        selected ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final Color foreground =
        selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    final BorderSide side = BorderSide(
      color: selected ? scheme.primary : scheme.outline,
      width: selected ? 1.5 : 1,
    );

    Widget chip = ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 48),
      child: Material(
        color: background,
        shape: StadiumBorder(side: side),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: EdgeInsetsDirectional.only(
                start: AppSpacing.l,
                end: onDeleted != null ? AppSpacing.xs : AppSpacing.l,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    letter,
                    style: AppTextStyles.headlineM.copyWith(color: foreground),
                  ),
                  if (onDeleted != null)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onDeleted,
                      child: Semantics(
                        button: true,
                        label: deleteSemanticLabel,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: Icon(
                              Icons.cancel_outlined,
                              size: 18,
                              color: foreground.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      chip = Semantics(
        selected: selected,
        label: semanticLabel,
        excludeSemantics: true,
        child: chip,
      );
    } else {
      chip = Semantics(selected: selected, child: chip);
    }
    return chip;
  }
}

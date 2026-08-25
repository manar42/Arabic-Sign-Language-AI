import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Compact trust chip for reassurance messages such as
/// "يعمل بدون إنترنت" / "المعالجة على جهازك فقط".
class TrustChip extends StatelessWidget {
  const TrustChip({
    super.key,
    required this.label,
    required this.icon,
    this.semanticLabel,
  });

  final String label;
  final IconData icon;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Widget chip = Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppRadius.brStadium,
        border: Border.all(color: scheme.outline),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.secondary),
          const SizedBox(width: AppSpacing.s),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelL.copyWith(color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        label: semanticLabel,
        excludeSemantics: true,
        child: chip,
      );
    }
    return chip;
  }
}

import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';

/// RTL-safe section header with an optional subtitle and trailing action.
///
/// Layout is direction-aware: content starts at the reading edge and the
/// trailing widget sits at the opposite edge in both LTR and RTL.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding =
        const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTextStyles.titleL.copyWith(color: scheme.onSurface),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodyM
                        .copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.l),
            trailing!,
          ],
        ],
      ),
    );
  }
}

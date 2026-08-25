import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_shadows.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Reusable selectable card for presenting a translation mode.
///
/// Presentation only: navigation and business logic stay in the caller
/// via [onTap]. Uses the foundation radius (large) and elevation (e1).
///
/// [emphasized] promotes the card to the filled primary variant: a
/// primary-container surface with a strong avatar and higher elevation,
/// reserved for the screen's single most important action.
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accent,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Optional accent used for the icon avatar; falls back to the
  /// theme's primary container tokens.
  final Color? accent;

  /// Optional widget rendered at the end of the card (RTL-aware).
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final Color surface =
        emphasized ? scheme.primaryContainer : scheme.surface;
    final Color borderColor = emphasized ? scheme.primary : scheme.outline;
    final Color avatarBackground = emphasized
        ? scheme.primary
        : accent?.withValues(alpha: 0.14) ?? scheme.primaryContainer;
    final Color avatarForeground =
        emphasized ? scheme.onPrimary : accent ?? scheme.onPrimaryContainer;
    final Color titleColor =
        emphasized ? scheme.onPrimaryContainer : scheme.onSurface;
    final Color subtitleColor =
        emphasized ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;

    final Widget card = Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadius.brLarge,
        border: Border.all(color: borderColor),
        boxShadow: emphasized ? AppShadows.e2 : AppShadows.e1,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.brLarge,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.l),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarBackground,
                    borderRadius: AppRadius.brSmall,
                  ),
                  child: Icon(icon, size: 24, color: avatarForeground),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleL
                            .copyWith(color: titleColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodyM
                            .copyWith(color: subtitleColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.m),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      return Semantics(
        button: onTap != null,
        label: semanticLabel,
        excludeSemantics: true,
        child: card,
      );
    }
    return Semantics(button: onTap != null, child: card);
  }
}

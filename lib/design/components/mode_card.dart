import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';
import '../app_typography.dart';

/// Luxury Modern Mode Card with subtle gradient, glowing accent border,
/// dynamic hover/tap scale, and premium typography.
class ModeCard extends StatefulWidget {
  const ModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.gradientColors,
    this.accent,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final List<Color>? gradientColors;
  final Color? accent;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final bool emphasized;

  @override
  State<ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<ModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color accentColor = widget.accent ?? scheme.primary;

    final List<Color> gradient = widget.gradientColors ??
        (widget.emphasized
            ? [
                accentColor.withValues(alpha: isDark ? 0.25 : 0.12),
                accentColor.withValues(alpha: isDark ? 0.10 : 0.04),
              ]
            : [
                isDark ? const Color(0xFF1E293B) : Colors.white,
                isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              ]);

    final Widget content = AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.brLarge,
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: gradient,
          ),
          border: Border.all(
            color: widget.emphasized
                ? accentColor.withValues(alpha: isDark ? 0.5 : 0.35)
                : scheme.outline.withValues(alpha: isDark ? 0.3 : 0.6),
            width: widget.emphasized ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.emphasized
                  ? accentColor.withValues(alpha: isDark ? 0.20 : 0.12)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: widget.emphasized ? 20 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: AppRadius.brLarge,
            onHighlightChanged: (pressed) => setState(() => _isPressed = pressed),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 26,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.l),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.badgeText != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.badgeText!,
                              style: AppTextStyles.caption.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                        Text(
                          widget.title,
                          style: AppTextStyles.titleL.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          widget.subtitle,
                          style: AppTextStyles.bodyM.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: AppSpacing.s),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.semanticLabel != null) {
      return Semantics(
        label: widget.semanticLabel,
        button: true,
        child: content,
      );
    }
    return content;
  }
}

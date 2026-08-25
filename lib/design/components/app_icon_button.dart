import 'package:flutter/material.dart';

/// Icon-only button variants.
enum AppIconButtonVariant { filled, tonal, transparent }

/// Presentation-only icon button with a guaranteed 48dp touch target
/// and required tooltip for accessibility.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.variant = AppIconButtonVariant.transparent,
    this.iconSize = 22,
  });

  final IconData icon;

  /// Accessibility tooltip; also shown on long press.
  final String tooltip;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    final ButtonStyle style = switch (variant) {
      AppIconButtonVariant.filled => IconButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          iconSize: iconSize,
          minimumSize: const Size(48, 48),
        ),
      AppIconButtonVariant.tonal => IconButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          iconSize: iconSize,
          minimumSize: const Size(48, 48),
        ),
      AppIconButtonVariant.transparent => IconButton.styleFrom(
          foregroundColor: scheme.onSurface,
          iconSize: iconSize,
          minimumSize: const Size(48, 48),
        ),
    };

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        style: style,
        icon: Icon(icon),
      ),
    );
  }
}

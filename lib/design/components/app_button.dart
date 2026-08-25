import 'package:flutter/material.dart';

import '../app_spacing.dart';

/// Visual variants supported by [AppButton].
enum AppButtonVariant { primary, tonal, outline, text }

/// Presentation-only button built on top of the app ThemeData.
///
/// Styling (stadium shape, 52dp minimum height, colors, disabled state)
/// comes from the theme foundations; this widget only wires variants,
/// an optional leading icon, a loading state and a full-width option.
///
/// When [expand] is used the nearest horizontal bounded parent provides
/// the width (e.g. a padded Column/ListView).
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  /// Shows a spinner in place of the icon and disables interaction.
  final bool loading;

  /// Stretches the button to the full available width.
  final bool expand;

  /// Overrides the accessibility label (screen readers announce this
  /// instead of the visible label).
  final String? semanticLabel;

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.primary;

  const AppButton.tonal({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.outline({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.outline;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = false,
    this.semanticLabel,
  }) : variant = AppButtonVariant.text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final VoidCallback? handler = loading ? null : onPressed;

    final Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              strokeCap: StrokeCap.round,
              color: _spinnerColor(scheme),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppSpacing.s),
        ],
        Flexible(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );

    Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: handler,
          child: child,
        ),
      AppButtonVariant.tonal => ElevatedButton(
          onPressed: handler,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.secondaryContainer,
            foregroundColor: scheme.onSecondaryContainer,
            elevation: 0,
          ),
          child: child,
        ),
      AppButtonVariant.outline => OutlinedButton(
          onPressed: handler,
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: handler,

          // The text-button theme does not enforce the shared 52dp height,
          // so the minimum size is applied here for variant parity.
          style: TextButton.styleFrom(minimumSize: const Size(64, 52)),
          child: child,
        ),
    };

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }
    if (semanticLabel != null) {
      button = Semantics(
        label: semanticLabel,
        button: true,
        excludeSemantics: true,
        child: button,
      );
    }
    return button;
  }

  Color _spinnerColor(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.primary => scheme.onPrimary,
        AppButtonVariant.tonal => scheme.onSecondaryContainer,
        AppButtonVariant.outline || AppButtonVariant.text => scheme.primary,
      };
}

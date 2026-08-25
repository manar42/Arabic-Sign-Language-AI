import 'package:flutter/material.dart';

/// Reusable Material 3 confirmation dialog.
///
/// Presentation only: returns `true` (confirm), `false` (cancel) or
/// `null` (dismissed). The dialog shape/typography come from the shared
/// [DialogTheme] foundation.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    this.description,
    this.destructive = false,
  });

  final String title;
  final String? description;
  final String confirmLabel;
  final String cancelLabel;

  /// Tints the confirm action with the error tokens for destructive
  /// confirmations.
  final bool destructive;

  /// Convenience helper for showing the dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? description,
    required String confirmLabel,
    required String cancelLabel,
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmDialog(
        title: title,
        description: description,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        destructive: destructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(title),
      content: description == null ? null : Text(description!),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

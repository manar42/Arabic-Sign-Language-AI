import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';
import 'app_button.dart';

/// Reusable error presentation with a retry action.
///
/// Covers future cases such as camera permission denied, initialization
/// failure or model loading failure. Presentation only: the caller owns
/// what "retry" actually does.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.retryLabel,
    required this.onRetry,
    this.description,
    this.secondaryLabel,
    this.onSecondaryAction,
    this.icon = Icons.error_outline,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  final String title;
  final String? description;

  final String retryLabel;
  final VoidCallback onRetry;

  /// Optional secondary action (e.g. open app settings).
  final String? secondaryLabel;
  final VoidCallback? onSecondaryAction;

  final IconData icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: scheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: scheme.onErrorContainer),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleL.copyWith(color: scheme.onSurface),
              ),
              if (description != null) ...[
                const SizedBox(height: AppSpacing.s),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyM
                      .copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              AppButton.primary(label: retryLabel, onPressed: onRetry),
              if (secondaryLabel != null && onSecondaryAction != null) ...[
                const SizedBox(height: AppSpacing.s),
                AppButton.text(
                  label: secondaryLabel!,
                  onPressed: onSecondaryAction,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

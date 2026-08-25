import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';
import 'app_button.dart';

/// Friendly empty-state presentation with an optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.icon,
    this.description,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  final String title;
  final String? description;
  final IconData icon;

  /// Optional call to action; rendered only when both label and
  /// callback are provided.
  final String? actionLabel;
  final VoidCallback? onAction;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(icon, size: 30, color: scheme.onSurfaceVariant),
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
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              AppButton.tonal(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}

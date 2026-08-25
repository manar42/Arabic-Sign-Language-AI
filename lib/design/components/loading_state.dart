import 'package:flutter/material.dart';

import '../app_spacing.dart';
import '../app_typography.dart';

/// Centered loading presentation with an optional title/description.
///
/// Purely presentational; no timers or state management inside.
class LoadingState extends StatelessWidget {
  const LoadingState({
    super.key,
    this.title,
    this.description,
    this.padding = const EdgeInsets.all(AppSpacing.xxl),
  });

  final String? title;
  final String? description;
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
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            if (title != null) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                title!,
                textAlign: TextAlign.center,
                style:
                    AppTextStyles.titleM.copyWith(color: scheme.onSurface),
              ),
            ],
            if (description != null) ...[
              const SizedBox(height: AppSpacing.s),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM
                    .copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

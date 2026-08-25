import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

ThemeData lightTheme() {
  const AppColorTokens c = AppColorsLight();
  return _buildTheme(c, inversePrimary: AppColors.dark.primary);
}

ThemeData darkTheme() {
  const AppColorTokens c = AppColorsDark();
  return _buildTheme(c, inversePrimary: AppColors.light.primary);
}

ThemeData _buildTheme(AppColorTokens c, {required Color inversePrimary}) {
  final ColorScheme scheme = ColorScheme(
    brightness: c.brightness,
    primary: c.primary,
    onPrimary: c.onPrimary,
    primaryContainer: c.primaryContainer,
    onPrimaryContainer: c.onPrimaryContainer,
    secondary: c.secondary,
    onSecondary: c.onSecondary,
    secondaryContainer: c.secondaryContainer,
    onSecondaryContainer: c.onSecondaryContainer,
    tertiary: c.success,
    onTertiary: c.onSuccess,
    tertiaryContainer: c.successContainer,
    onTertiaryContainer: c.onSuccessContainer,
    error: c.error,
    onError: c.onError,
    errorContainer: c.errorContainer,
    onErrorContainer: c.onErrorContainer,
    surface: c.surface,
    onSurface: c.textPrimary,
    surfaceContainerHighest: c.surfaceVariant,
    onSurfaceVariant: c.textSecondary,
    outline: c.outline,
    outlineVariant: c.outlineVariant,
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: c.inverseSurface,
    onInverseSurface: c.inverseOnSurface,
    inversePrimary: inversePrimary,
    surfaceTint: Colors.transparent,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.background,
    fontFamily: AppFonts.body,
    textTheme: _textTheme(c),
    appBarTheme: AppBarTheme(
      backgroundColor: c.background,
      foregroundColor: c.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.titleL.copyWith(color: c.textPrimary),
      iconTheme: IconThemeData(color: c.textPrimary),
      actionsIconTheme: IconThemeData(color: c.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: c.surface,
      elevation: 1,
      shadowColor: c.shadowTint,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brLarge),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(AppTextStyles.labelL),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.disabledBg
              : c.primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? c.disabledFg
              : c.onPrimary,
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.m),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(AppTextStyles.labelL),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? c.disabledFg : c.primary,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: c.outline, width: 1.5)),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.m),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: const WidgetStatePropertyAll(AppTextStyles.labelL),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.disabled) ? c.disabledFg : c.primary,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      hintStyle: AppTextStyles.bodyM.copyWith(color: c.textSecondary),
      labelStyle: AppTextStyles.bodyM.copyWith(color: c.textSecondary),
      border: OutlineInputBorder(
        borderRadius: AppRadius.brMedium,
        borderSide: BorderSide(color: c.outline, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.brMedium,
        borderSide: BorderSide(color: c.outline, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.brMedium,
        borderSide: BorderSide(color: c.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.brMedium,
        borderSide: BorderSide(color: c.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.brMedium,
        borderSide: BorderSide(color: c.error, width: 2),
      ),
      errorStyle: AppTextStyles.caption.copyWith(color: c.error),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.surfaceVariant,
      selectedColor: c.primaryContainer,
      checkmarkColor: c.primary,
      deleteIconColor: c.textSecondary,
      labelStyle: AppTextStyles.labelL.copyWith(color: c.textPrimary),
      secondaryLabelStyle:
          AppTextStyles.labelL.copyWith(color: c.onPrimaryContainer),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.s,
      ),
    ),
    dividerTheme: DividerThemeData(color: c.outline, thickness: 1, space: 1),
    dividerColor: c.outline,
    iconTheme: IconThemeData(size: 24, color: c.textPrimary),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.brExtraLarge),
      titleTextStyle: AppTextStyles.titleL.copyWith(color: c.textPrimary),
      contentTextStyle: AppTextStyles.bodyL.copyWith(color: c.textPrimary),
    ),
  );
}

TextTheme _textTheme(AppColorTokens c) {
  final Color primary = c.textPrimary;
  final Color secondary = c.textSecondary;
  return TextTheme(
    displayLarge: AppTextStyles.displayL.copyWith(color: primary),
    displayMedium: AppTextStyles.displayM.copyWith(color: primary),
    displaySmall: AppTextStyles.displayM.copyWith(color: primary),
    headlineLarge: AppTextStyles.headlineL.copyWith(color: primary),
    headlineMedium: AppTextStyles.headlineM.copyWith(color: primary),
    headlineSmall: AppTextStyles.headlineM.copyWith(color: primary),
    titleLarge: AppTextStyles.titleL.copyWith(color: primary),
    titleMedium: AppTextStyles.titleM.copyWith(color: primary),
    titleSmall: AppTextStyles.labelL.copyWith(color: primary),
    bodyLarge: AppTextStyles.bodyL.copyWith(color: primary),
    bodyMedium: AppTextStyles.bodyM.copyWith(color: primary),
    bodySmall: AppTextStyles.caption.copyWith(color: secondary),
    labelLarge: AppTextStyles.labelL.copyWith(color: primary),
    labelMedium: AppTextStyles.caption.copyWith(color: primary),
    labelSmall: AppTextStyles.caption.copyWith(color: secondary),
  );
}

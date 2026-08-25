import 'package:flutter/material.dart';

/// Semantic color token set shared by the light and dark palettes.
sealed class AppColorTokens {
  const AppColorTokens();

  Brightness get brightness;

  Color get primary;
  Color get onPrimary;
  Color get primaryContainer;
  Color get onPrimaryContainer;

  Color get secondary;
  Color get onSecondary;
  Color get secondaryContainer;
  Color get onSecondaryContainer;

  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get outline;
  Color get outlineVariant;

  Color get textPrimary;
  Color get textSecondary;

  Color get success;
  Color get onSuccess;
  Color get successContainer;
  Color get onSuccessContainer;

  Color get warning;

  Color get error;
  Color get onError;
  Color get errorContainer;
  Color get onErrorContainer;

  Color get disabledBg;
  Color get disabledFg;
  Color get shadowTint;

  Color get inverseSurface;
  Color get inverseOnSurface;
}

class AppColorsLight extends AppColorTokens {
  const AppColorsLight();

  @override
  final Brightness brightness = Brightness.light;

  @override
  final Color primary = const Color(0xFF0F766E);
  @override
  final Color onPrimary = const Color(0xFFFFFFFF);
  @override
  final Color primaryContainer = const Color(0xFFCCFBF1);
  @override
  final Color onPrimaryContainer = const Color(0xFF134E4A);

  @override
  final Color secondary = const Color(0xFFB45309);
  @override
  final Color onSecondary = const Color(0xFFFFFFFF);
  @override
  final Color secondaryContainer = const Color(0xFFFEF3C7);
  @override
  final Color onSecondaryContainer = const Color(0xFF78350F);

  @override
  final Color background = const Color(0xFFFAF9F7);
  @override
  final Color surface = const Color(0xFFFFFFFF);
  @override
  final Color surfaceVariant = const Color(0xFFF0EDE8);
  @override
  final Color outline = const Color(0xFFE7E2DC);
  @override
  final Color outlineVariant = const Color(0xFFF0EDE8);

  @override
  final Color textPrimary = const Color(0xFF1C1917);
  @override
  final Color textSecondary = const Color(0xFF57534E);

  @override
  final Color success = const Color(0xFF15803D);
  @override
  final Color onSuccess = const Color(0xFFFFFFFF);
  @override
  final Color successContainer = const Color(0xFFDCFCE7);
  @override
  final Color onSuccessContainer = const Color(0xFF14532D);

  @override
  final Color warning = const Color(0xFFB45309);

  @override
  final Color error = const Color(0xFFB91C1C);
  @override
  final Color onError = const Color(0xFFFFFFFF);
  @override
  final Color errorContainer = const Color(0xFFFEE2E2);
  @override
  final Color onErrorContainer = const Color(0xFF7F1D1D);

  @override
  final Color disabledBg = const Color(0x1F1C1917);
  @override
  final Color disabledFg = const Color(0x611C1917);
  @override
  final Color shadowTint = const Color(0x14000000);

  @override
  final Color inverseSurface = const Color(0xFF1C1917);
  @override
  final Color inverseOnSurface = const Color(0xFFFAF9F7);
}

class AppColorsDark extends AppColorTokens {
  const AppColorsDark();

  @override
  final Brightness brightness = Brightness.dark;

  @override
  final Color primary = const Color(0xFF2DD4BF);
  @override
  final Color onPrimary = const Color(0xFF042F2E);
  @override
  final Color primaryContainer = const Color(0xFF115E59);
  @override
  final Color onPrimaryContainer = const Color(0xFF99F6E4);

  @override
  final Color secondary = const Color(0xFFFBBF24);
  @override
  final Color onSecondary = const Color(0xFF451A03);
  @override
  final Color secondaryContainer = const Color(0xFF78350F);
  @override
  final Color onSecondaryContainer = const Color(0xFFFDE68A);

  @override
  final Color background = const Color(0xFF161311);
  @override
  final Color surface = const Color(0xFF211D1A);
  @override
  final Color surfaceVariant = const Color(0xFF2B2621);
  @override
  final Color outline = const Color(0xFF3A332C);
  @override
  final Color outlineVariant = const Color(0xFF2B2621);

  @override
  final Color textPrimary = const Color(0xFFF5F5F4);
  @override
  final Color textSecondary = const Color(0xFFA8A29E);

  @override
  final Color success = const Color(0xFF4ADE80);
  @override
  final Color onSuccess = const Color(0xFF052E16);
  @override
  final Color successContainer = const Color(0xFF14532D);
  @override
  final Color onSuccessContainer = const Color(0xFFDCFCE7);

  @override
  final Color warning = const Color(0xFFFBBF24);

  @override
  final Color error = const Color(0xFFF87171);
  @override
  final Color onError = const Color(0xFF450A0A);
  @override
  final Color errorContainer = const Color(0xFF7F1D1D);
  @override
  final Color onErrorContainer = const Color(0xFFFEE2E2);

  @override
  final Color disabledBg = const Color(0x1FF5F5F4);
  @override
  final Color disabledFg = const Color(0x61F5F5F4);
  @override
  final Color shadowTint = const Color(0x40000000);

  @override
  final Color inverseSurface = const Color(0xFFFAF9F7);
  @override
  final Color inverseOnSurface = const Color(0xFF161311);
}

/// Entry point for accessing the active palettes.
class AppColors {
  const AppColors._();

  static const AppColorTokens light = AppColorsLight();
  static const AppColorTokens dark = AppColorsDark();
}

/// Camera overlay tokens. Reserved for the Sign->Text redesign phase;
/// intentionally unused by any screen right now.
class AppCameraColors {
  const AppCameraColors._();

  static const Color cameraScrim = Color(0x8C141210);
  static const Color guideIdle = Color(0xCC99F6E4);
  static const Color guideDetected = Color(0xFF34D399);
  static const Color landmarkLine = Color(0xA6FFFFFF);
  static const Color landmarkPoint = Color(0xFF5EEAD4);
  static const Color statusPillBackground = Color(0xB3141210);
}

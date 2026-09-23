import 'package:flutter/material.dart';

/// Semantic color tokens defining a luxurious, deep-tech identity.
/// Features royal deep navy / obsidian backgrounds, luminous emerald & cyan accents,
/// and warm gold secondary highlights.
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

  Color get accentGlow;
  Color get cardGradientStart;
  Color get cardGradientEnd;

  Color get background;
  Color get surface;
  Color get surfaceVariant;
  Color get outline;
  Color get outlineVariant;

  Color get textPrimary;
  Color get textSecondary;
  Color get textTertiary;

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

  // Luminous emerald / royal cyan primary
  @override
  final Color primary = const Color(0xFF0D9488);
  @override
  final Color onPrimary = const Color(0xFFFFFFFF);
  @override
  final Color primaryContainer = const Color(0xFFE6FFFA);
  @override
  final Color onPrimaryContainer = const Color(0xFF0F766E);

  // Warm Amber / Luxury Gold secondary
  @override
  final Color secondary = const Color(0xFFD97706);
  @override
  final Color onSecondary = const Color(0xFFFFFFFF);
  @override
  final Color secondaryContainer = const Color(0xFFFEF3C7);
  @override
  final Color onSecondaryContainer = const Color(0xFF92400E);

  @override
  final Color accentGlow = const Color(0x330D9488);
  @override
  final Color cardGradientStart = const Color(0xFFFFFFFF);
  @override
  final Color cardGradientEnd = const Color(0xFFF8FAFC);

  @override
  final Color background = const Color(0xFFF1F5F9);
  @override
  final Color surface = const Color(0xFFFFFFFF);
  @override
  final Color surfaceVariant = const Color(0xFFE2E8F0);
  @override
  final Color outline = const Color(0xFFCBD5E1);
  @override
  final Color outlineVariant = const Color(0xFFE2E8F0);

  @override
  final Color textPrimary = const Color(0xFF0F172A);
  @override
  final Color textSecondary = const Color(0xFF475569);
  @override
  final Color textTertiary = const Color(0xFF94A3B8);

  @override
  final Color success = const Color(0xFF10B981);
  @override
  final Color onSuccess = const Color(0xFFFFFFFF);
  @override
  final Color successContainer = const Color(0xFFD1FAE5);
  @override
  final Color onSuccessContainer = const Color(0xFF065F46);

  @override
  final Color warning = const Color(0xFFF59E0B);

  @override
  final Color error = const Color(0xFFEF4444);
  @override
  final Color onError = const Color(0xFFFFFFFF);
  @override
  final Color errorContainer = const Color(0xFFFEE2E2);
  @override
  final Color onErrorContainer = const Color(0xFF991B1B);

  @override
  final Color disabledBg = const Color(0x1F0F172A);
  @override
  final Color disabledFg = const Color(0x610F172A);
  @override
  final Color shadowTint = const Color(0x0F0F172A);

  @override
  final Color inverseSurface = const Color(0xFF0F172A);
  @override
  final Color inverseOnSurface = const Color(0xFFF8FAFC);
}

class AppColorsDark extends AppColorTokens {
  const AppColorsDark();

  @override
  final Brightness brightness = Brightness.dark;

  // Luminous high-tech neon emerald
  @override
  final Color primary = const Color(0xFF14B8A6);
  @override
  final Color onPrimary = const Color(0xFF042F2E);
  @override
  final Color primaryContainer = const Color(0xFF134E4A);
  @override
  final Color onPrimaryContainer = const Color(0xFF5EEAD4);

  // Radiant Gold
  @override
  final Color secondary = const Color(0xFFF59E0B);
  @override
  final Color onSecondary = const Color(0xFF451A03);
  @override
  final Color secondaryContainer = const Color(0xFF78350F);
  @override
  final Color onSecondaryContainer = const Color(0xFFFDE68A);

  @override
  final Color accentGlow = const Color(0x4D14B8A6);
  @override
  final Color cardGradientStart = const Color(0xFF1E293B);
  @override
  final Color cardGradientEnd = const Color(0xFF0F172A);

  // Deep Obsidian / Royal Midnight Blue
  @override
  final Color background = const Color(0xFF0B0F17);
  @override
  final Color surface = const Color(0xFF151C28);
  @override
  final Color surfaceVariant = const Color(0xFF1E293B);
  @override
  final Color outline = const Color(0xFF334155);
  @override
  final Color outlineVariant = const Color(0xFF1E293B);

  @override
  final Color textPrimary = const Color(0xFFF8FAFC);
  @override
  final Color textSecondary = const Color(0xFF94A3B8);
  @override
  final Color textTertiary = const Color(0xFF64748B);

  @override
  final Color success = const Color(0xFF10B981);
  @override
  final Color onSuccess = const Color(0xFF064E3B);
  @override
  final Color successContainer = const Color(0xFF065F46);
  @override
  final Color onSuccessContainer = const Color(0xFFA7F3D0);

  @override
  final Color warning = const Color(0xFFF59E0B);

  @override
  final Color error = const Color(0xFFF87171);
  @override
  final Color onError = const Color(0xFF450A0A);
  @override
  final Color errorContainer = const Color(0xFF7F1D1D);
  @override
  final Color onErrorContainer = const Color(0xFFFECACA);

  @override
  final Color disabledBg = const Color(0x1FFFFFFF);
  @override
  final Color disabledFg = const Color(0x61FFFFFF);
  @override
  final Color shadowTint = const Color(0x40000000);

  @override
  final Color inverseSurface = const Color(0xFFF8FAFC);
  @override
  final Color inverseOnSurface = const Color(0xFF0F172A);
}

class AppColors {
  const AppColors._();

  static const AppColorsLight light = AppColorsLight();
  static const AppColorsDark dark = AppColorsDark();

  static AppColorTokens of(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
}

/// Specialized colors for the camera HUD, landmarks and detector feedback.
class AppCameraColors {
  const AppCameraColors._();

  static const Color guideIdle = Color(0x66FFFFFF);
  static const Color guideDetected = Color(0xFF14B8A6);
  static const Color landmarkPoint = Color(0xFF14B8A6);
  static const Color landmarkLine = Color(0xCC0D9488);
  static const Color statusSearching = Color(0xCC0F172A);
  static const Color statusDetected = Color(0xCC134E4A);
  static const Color statusPillBackground = Color(0xCC0B0F17);
  static const Color cameraScrim = Color(0xFF0B0F17);
  static const Color statusText = Color(0xFFFFFFFF);
}

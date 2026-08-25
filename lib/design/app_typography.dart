import 'package:flutter/material.dart';

/// Font families for the Calm Intelligence identity.
///
/// NOTE: Cairo and IBM Plex Sans Arabic TTF files are NOT bundled yet.
/// Until they are added under `assets/fonts/` and declared in pubspec.yaml,
/// Flutter safely falls back to the platform default font.
/// TODO(fonts): bundle Cairo + IBM Plex Sans Arabic in a later phase.
class AppFonts {
  const AppFonts._();

  static const String display = 'Cairo';
  static const String body = 'IBM Plex Sans Arabic';
}

/// Typography scale tokens. Sizes/heights are fixed; colors are applied
/// by the theme so tokens stay neutral.
class AppTextStyles {
  const AppTextStyles._();

  static const TextStyle displayL = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 64,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle displayM = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 45,
    height: 1.20,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineL = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 32,
    height: 1.30,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineM = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    height: 1.30,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleL = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 20,
    height: 1.35,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleM = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 17,
    height: 1.40,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodyL = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 16,
    height: 1.55,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyM = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelL = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 13,
    height: 1.40,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 12,
    height: 1.40,
    fontWeight: FontWeight.w400,
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font definitions for premium, modern typography with Arabic & English support.
class AppFonts {
  const AppFonts._();

  static String get display => GoogleFonts.cairo().fontFamily ?? 'Cairo';
  static String get body => GoogleFonts.tajawal().fontFamily ?? 'Tajawal';
}

/// Typography scale tokens powered by GoogleFonts for crisp, luxury rendering.
class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get displayL => GoogleFonts.cairo(
        fontSize: 48,
        height: 1.15,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      );

  static TextStyle get displayM => GoogleFonts.cairo(
        fontSize: 36,
        height: 1.20,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineL => GoogleFonts.cairo(
        fontSize: 28,
        height: 1.25,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get headlineM => GoogleFonts.cairo(
        fontSize: 22,
        height: 1.30,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get titleL => GoogleFonts.cairo(
        fontSize: 19,
        height: 1.35,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleM => GoogleFonts.tajawal(
        fontSize: 16,
        height: 1.40,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get bodyL => GoogleFonts.tajawal(
        fontSize: 15,
        height: 1.55,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyM => GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.50,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyS => GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get labelL => GoogleFonts.cairo(
        fontSize: 15,
        height: 1.30,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get labelM => GoogleFonts.cairo(
        fontSize: 13,
        height: 1.30,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get caption => GoogleFonts.tajawal(
        fontSize: 12,
        height: 1.40,
        fontWeight: FontWeight.w400,
      );
}

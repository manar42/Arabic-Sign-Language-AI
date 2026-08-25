import 'package:flutter/material.dart';

/// Corner radius scale.
class AppRadius {
  const AppRadius._();

  static const double small = 12;
  static const double medium = 16;
  static const double large = 20;
  static const double extraLarge = 28;
  static const double stadium = 999;

  static const BorderRadius brSmall = BorderRadius.all(Radius.circular(small));
  static const BorderRadius brMedium = BorderRadius.all(Radius.circular(medium));
  static const BorderRadius brLarge = BorderRadius.all(Radius.circular(large));
  static const BorderRadius brExtraLarge =
      BorderRadius.all(Radius.circular(extraLarge));
  static const BorderRadius brStadium =
      BorderRadius.all(Radius.circular(stadium));
}

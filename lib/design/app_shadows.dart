import 'package:flutter/material.dart';

/// Elevation system.
///
/// e0: no shadow, outline only.
/// e1: mode cards / result tiles.
/// e2: floating control panels.
/// e3: dialogs.
class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> e0 = <BoxShadow>[];

  static const List<BoxShadow> e1 = <BoxShadow>[
    BoxShadow(offset: Offset(0, 2), blurRadius: 8, color: Color(0x0F000000)),
  ];

  static const List<BoxShadow> e2 = <BoxShadow>[
    BoxShadow(offset: Offset(0, 4), blurRadius: 16, color: Color(0x14000000)),
  ];

  static const List<BoxShadow> e3 = <BoxShadow>[
    BoxShadow(offset: Offset(0, 8), blurRadius: 28, color: Color(0x1F000000)),
  ];
}

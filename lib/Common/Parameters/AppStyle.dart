import 'package:flutter/material.dart';

class AppStyle {
  static LinearGradient backgroundGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(27, 23, 137, 0.6),
        Color.fromRGBO(31, 31, 31, 1.0)
      ],
      stops: [
        0.01,
        0.4
      ]);

  static LinearGradient getStandardPaletteWithAnotherMainColor(Color color) {
    return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, const Color.fromRGBO(31, 31, 31, 1.0)],
        stops: const [0.01, 0.4]);
  }

  static Color text = const Color.fromRGBO(255, 255, 255, 0.8);
  static Color primaryBackground = const Color.fromRGBO(56, 56, 56, 0.8);
  static Color switchActiveColor = const Color.fromRGBO(255, 255, 255, 1);
  static Color switchInactiveColor = const Color.fromRGBO(255, 255, 255, 0.6);
  static Color ShimmerColorBase = const Color.fromRGBO(31, 31, 31, 1.0);
  static Color ShimmerColorBackground = const Color.fromRGBO(68, 68, 68, 1.0);

  static TextStyle textStyle = const TextStyle(color: Colors.white);
  static TextStyle titleStyle =
      const TextStyle(color: Colors.white, fontSize: 15);
  static Color scaffoldBackgroundColor = Colors.blue;
  static BoxDecoration scaffoldDecoration = BoxDecoration(
      gradient: AppStyle.getStandardPaletteWithAnotherMainColor(
          AppStyle.scaffoldBackgroundColor));

  
}

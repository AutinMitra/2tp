import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';

class Themes {
  static final ThemeData lightMode = ThemeData(
    accentColor: Palette.accent,
    primaryColor: Palette.primary,
    backgroundColor: Palette.bgLight,
    scaffoldBackgroundColor: Palette.bgLight,
    cardColor: Palette.bgLight,
    canvasColor: Palette.bgLight,
    brightness: Brightness.light,
    primaryColorBrightness: Brightness.light,
    buttonTheme: ButtonThemeData(
      buttonColor: Palette.primary,
      textTheme: ButtonTextTheme.accent,
      padding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0
    ),
    fontFamily: 'Manrope'
  );
}
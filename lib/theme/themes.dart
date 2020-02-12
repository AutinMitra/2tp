import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';

class Themes {
  static final ThemeData lightMode = ThemeData(
    accentColor: Palette.accent,
    primaryColor: Palette.primary,
    backgroundColor: Palette.bgLight,
    scaffoldBackgroundColor: Palette.scLight,
    cardColor: Palette.bgLight,
    canvasColor: Palette.bgLight,
    brightness: Brightness.light,
    primaryColorBrightness: Brightness.light,
    buttonTheme: ButtonThemeData(
      padding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0
    ),
    fontFamily: 'Manrope'
  );

  static final ThemeData darkMode = ThemeData(
    accentColor: Palette.accent,
    primaryColor: Palette.primary,
    backgroundColor: Palette.bgDark,
    scaffoldBackgroundColor: Palette.scDark,
    cardColor: Palette.bgDark,
    canvasColor: Palette.bgDark,
    brightness: Brightness.dark,
    primaryColorBrightness: Brightness.dark,
    buttonTheme: ButtonThemeData(
      padding: EdgeInsets.all(12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0
    ),
    fontFamily: 'Manrope'
  );
}
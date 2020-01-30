import 'package:flutter/material.dart';

class ColorUtils {
  static Color changeAlphaValue(Color c, int alpha) {
    return Color((c.value & 0x00FFFFFF) | (alpha << 24));
  }
}

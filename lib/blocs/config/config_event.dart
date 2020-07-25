import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

// Changing the theme mode
// 0 - light
// 1 - dark
// 2 - system specified
class ChangeConfigThemeEvent extends ConfigEvent {
  final int value;

  static const int LIGHT = 0;
  static const int DARK = 1;
  static const int SYSTEM = 2;

  ChangeConfigThemeEvent(this.value) : assert(value >= 0 && value <= 2);
}

class ChangeConfigFingerprintEvent extends ConfigEvent {
  final bool enabled;

  ChangeConfigFingerprintEvent(this.enabled) : assert(enabled != null);
}

// Loading the settings
class FetchConfigEvent extends ConfigEvent { }
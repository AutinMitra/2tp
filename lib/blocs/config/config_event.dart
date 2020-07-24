import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

// Changing the theme mode
// 0 - light
// 1 - dark
// 2 - system specified
class ChangeConfigThemeEvent extends ConfigEvent {
  final int value;

  static int LIGHT_MODE = 0;
  static int DARK_MODE = 1;
  static int SYSTEM = 2;

  ChangeConfigThemeEvent(this.value) : assert(value >= 0 && value <= 2);
}

class ChangeConfigFingerprintEvent extends ConfigEvent {
  final bool enabled;

  ChangeConfigFingerprintEvent(this.enabled) : assert(enabled != null);
}

// Loading the settings
class FetchConfigEvent extends ConfigEvent { }
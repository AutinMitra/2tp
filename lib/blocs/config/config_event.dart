import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

// Changing the theme mode
// 0 - light
// 1 - dark
// 2 - system specified
class ChangeConfigThemeEvent extends ConfigEvent {
  final int value;

  ChangeConfigThemeEvent(this.value) : assert(value >= 0 && value <= 2);
}

// Loading the settings
class FetchConfigEvent extends ConfigEvent { }
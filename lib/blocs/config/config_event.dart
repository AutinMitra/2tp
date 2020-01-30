import 'dart:io';
import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

class ChangeDarkMode extends ConfigEvent {
  static const int LIGHT_MODE = 0;
  static const int DARK_MODE = 1;
  static const int FOLLOW_SYSTEM = 2;

  final int value;

  ChangeDarkMode(this.value) : assert(value >= 0 && value <= 2);
}

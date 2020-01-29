import 'dart:io';
import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

class ConfigValueChanged extends ConfigEvent {
  final String key;
  final bool value;
  ConfigValueChanged(this.key, this.value);
}




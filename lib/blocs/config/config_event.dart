import 'package:flutter/material.dart';

@immutable
abstract class ConfigEvent {}

class ChangeConfigEvent extends ConfigEvent {
  final int value;

  ChangeConfigEvent(this.value) : assert(value >= 0 && value <= 2);
}

class FetchConfigEvent extends ConfigEvent { }
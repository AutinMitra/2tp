import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ConfigState extends Equatable {
  final List configProps;
  ConfigState([this.configProps]) : super();

  @override
  List<Object> get props => configProps;
  ConfigState getStateCopy();
}

// Uninitialized Configuration
class UnitConfigState extends ConfigState {
  @override
  String toString() {
    return "UnitConfigState";
  }

  @override
  ConfigState getStateCopy() {
    return UnitConfigState();
  }
}

class InitConfigState extends ConfigState {
  @override
  String toString() {
    return "InitConfigState";
  }

  @override
  ConfigState getStateCopy() {
    return InitConfigState();
  }
}
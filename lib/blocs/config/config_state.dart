import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ConfigState extends Equatable {
  final List configProps;
  ConfigState([this.configProps]) : super();

  @override
  List<Object> get props => configProps;
}

// Uninitialized Configuration
class UnitConfigState extends ConfigState {
  @override
  String toString() {
    return "UnitConfigState";
  }
}

// Initialized config
class InitConfigState extends ConfigState {
  @override
  String toString() {
    return "InitConfigState";
  }
}

// Error happened in config
class ErrorConfigState extends ConfigState {
  final String error;

  ErrorConfigState(this.error);

  @override
  String toString() {
    return "ErrorConfigState";
  }
}
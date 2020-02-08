import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ConfigState extends Equatable {
  final List _props;

  ConfigState([this._props]) : super();

  @override
  List<Object> get props => _props;
}

// Uninitialized Configuration
class UnitConfigState extends ConfigState {
  @override
  String toString() {
    return "UnitConfigState";
  }
}

// Initialized config
class ChangedConfigState extends ConfigState {
  final int value;

  ChangedConfigState(this.value) : super([value]);
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
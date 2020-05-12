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
class UnitConfigState extends ConfigState { }

// Initialized config
class ChangedConfigState extends ConfigState {
  final int themeValue;

  ChangedConfigState({
    @required this.themeValue,
  })
      : assert(themeValue != null),
        super([themeValue]);

  ChangedConfigState copyWith({themeValue}) {
    return ChangedConfigState(
        themeValue: themeValue
    );
  }
}

// Error happened in config
class ErrorConfigState extends ConfigState {
  final String error;

  ErrorConfigState(this.error);
}
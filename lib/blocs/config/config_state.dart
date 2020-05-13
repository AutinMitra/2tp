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
  final bool biometricsEnabled;

  ChangedConfigState({
    this.themeValue = 2,
    this.biometricsEnabled = false,
  })
      : super([themeValue, biometricsEnabled]);

  ChangedConfigState copyWith({themeValue, biometricsEnabled}) {
    return ChangedConfigState(
        themeValue: themeValue ?? this.themeValue,
        biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled
    );
  }
}

// Error happened in config
class ErrorConfigState extends ConfigState {
  final String error;

  ErrorConfigState(this.error);
}
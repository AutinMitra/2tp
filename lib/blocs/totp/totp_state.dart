import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class TOTPState extends Equatable {
  final List _props;
  TOTPState([this._props]) : super();

  @override
  List get props => props;
}

class UnitTOTPState extends TOTPState {}
class InitTOTPState extends TOTPState {}
class ErrorTOTPState extends TOTPState {
  final String error;

  ErrorTOTPState(this.error);

  @override
  String toString() {
    return "ErrorConfigState";
  }
}
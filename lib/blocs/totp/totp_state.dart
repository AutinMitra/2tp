import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:twotp/totp/totp.dart';

// The base TOTP state for the TOTPItems
class TOTPState extends Equatable {
  final List _props;
  TOTPState([this._props]) : super();

  @override
  List get props => _props;
}

// When the application is loading or retrieving data
class UnitTOTPState extends TOTPState {}

// Everything is loaded, or there has been a change
class ChangedTOTPState extends TOTPState {
  final List<TOTPItem> items;

  ChangedTOTPState(this.items) : super([items]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          super == other &&
              other is ChangedTOTPState &&
              runtimeType == other.runtimeType &&
              listEquals(items, other.items);

  @override
  int get hashCode =>
      super.hashCode ^
      items.hashCode;


}

// Uh oh - there's been an error
class ErrorTOTPState extends TOTPState {
  final String error;

  ErrorTOTPState(this.error) : super([error]);
}
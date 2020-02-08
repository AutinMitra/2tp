import 'package:equatable/equatable.dart';

class TOTPState extends Equatable {
  final List _props;
  TOTPState([this._props]) : super();

  @override
  List get props => _props;
}

class UnitTOTPState extends TOTPState {}
class ChangedTOTPState extends TOTPState {
  final List items;

  ChangedTOTPState(this.items) : super([items]);
}
class ErrorTOTPState extends TOTPState {
  final String error;

  ErrorTOTPState(this.error) : super([error]);
}
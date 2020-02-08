import 'package:flutter/material.dart';
import 'package:twotp/totp/totp.dart';

@immutable
abstract class TOTPEvent {}

class FetchItemsEvent extends TOTPEvent {}

class AddItemEvent extends TOTPEvent {
  final TOTPItem item;
  AddItemEvent(this.item);
}

class RemoveItemEvent extends TOTPEvent {
  final TOTPItem item;
  RemoveItemEvent(this.item);
}

class ReplaceItemEvent extends TOTPEvent {
  final TOTPItem a, b;

  ReplaceItemEvent(this.a, this.b);
}

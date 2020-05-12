import 'package:flutter/material.dart';
import 'package:twotp/totp/totp.dart';

@immutable
abstract class TOTPEvent {}

// Fetches storage for items
class FetchItemsEvent extends TOTPEvent {}

// Adds a new item
class AddItemEvent extends TOTPEvent {
  final TOTPItem item;
  AddItemEvent(this.item);
}

// Removes an item
class RemoveItemEvent extends TOTPEvent {
  final TOTPItem item;
  RemoveItemEvent(this.item);
}

// Replaces an item
class ReplaceItemEvent extends TOTPEvent {
  final TOTPItem a, b;

  ReplaceItemEvent(this.a, this.b);
}

// Moves an item from one index to another
class MoveItemEvent extends TOTPEvent {
  final int from, to;

  MoveItemEvent(this.from, this.to);
}

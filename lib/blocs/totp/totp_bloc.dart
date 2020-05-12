import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/twotp_utils.dart';

class TOTPBloc extends Bloc<TOTPEvent, TOTPState> {
  final String _filename = TwoTPUtils.prefsJSON;

  @override
  TOTPState get initialState => UnitTOTPState();

  @override
  Stream<TOTPState> mapEventToState(TOTPEvent event) async* {
    // Maps different types of events to
    if (event is FetchItemsEvent) {
      yield* mapFetchItemsEventToState(event);
    } else if (event is AddItemEvent) {
      yield* mapAddItemEventToState(event);
    } else if (event is RemoveItemEvent) {
      yield* mapRemoveItemEventToState(event);
    } else if (event is ReplaceItemEvent) {
      yield* mapReplaceItemEventToState(event);
    } else if (event is MoveItemEvent) {
      yield* mapMoveItemEventToState(event);
    }
  }

  Stream<TOTPState> mapFetchItemsEventToState(FetchItemsEvent event) async* {
    // Get the current state's items
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      items = await TwoTPUtils.loadItemsFromFile(_filename);
      yield ChangedTOTPState(items);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapAddItemEventToState(AddItemEvent event) async* {
    // Get the current state's items
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      // Add the item if it isn't a duplicate
      if (!items.contains(event.item))
        items.add(event.item);
      yield ChangedTOTPState(items);
      // Save the data to storage
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapRemoveItemEventToState(RemoveItemEvent event) async* {
    // Get the current state's items
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      // Remove the item from storage
      TwoTPUtils.removeFromSecureStorage(event.item);
      // Remove the item from state
      items.remove(event.item);
      yield ChangedTOTPState(items);
      // Save changes
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapReplaceItemEventToState(ReplaceItemEvent event) async* {
    // Get the current state's items
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      // Remove the old TOTPItem
      TwoTPUtils.removeFromSecureStorage(event.a);
      // Get the index of the old TOTPItem
      int aIndex = items.indexOf(event.a);
      // Set a replacement
      items[aIndex] = event.b;
      yield ChangedTOTPState(items);
      // Save all changes to storage
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapMoveItemEventToState(MoveItemEvent event) async* {
    // Get the current state's items
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      // Remove a TOTPItem at index [event.from] and move it to [event.to]
      var item = items[event.from];
      items.removeAt(event.from);
      // Sometimes the reorderAble list reports an index out of bounds, so cap it
      items.insert(min(event.to, items.length), item);
      yield ChangedTOTPState(items);
      // Save your changes
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }
}

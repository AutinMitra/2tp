import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/twotp_utils.dart';

class TOTPBloc extends Bloc<TOTPEvent, TOTPState> {
  final String _filename = 'totp_items.json';

  @override
  TOTPState get initialState => UnitTOTPState();

  @override
  Stream<TOTPState> mapEventToState(TOTPEvent event) async* {
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
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      if (!items.contains(event.item))
        items.add(event.item);
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapRemoveItemEventToState(RemoveItemEvent event) async* {
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      TwoTPUtils.removeFromSecureStorage(event.item);
      items.remove(event.item);
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapReplaceItemEventToState(ReplaceItemEvent event) async* {
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      TwoTPUtils.removeFromSecureStorage(event.a);
      int aIndex = items.indexOf(event.a);
      items[aIndex] = event.b;
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapMoveItemEventToState(MoveItemEvent event) async* {
    List<TOTPItem> items = [];
    if (state is ChangedTOTPState)
      items.addAll((state as ChangedTOTPState).items);
    try {
      var item = items[event.from];
      items.removeAt(event.from);
      items.insert(min(event.to, items.length), item);
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }
}

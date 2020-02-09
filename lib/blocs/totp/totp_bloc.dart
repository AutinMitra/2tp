import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/twotp_utils.dart';

class TOTPBloc extends Bloc<TOTPEvent, TOTPState> {
  final String _filename = 'totp_items.json';

  List<TOTPItem> items = [];

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
    }
  }

  Stream<TOTPState> mapFetchItemsEventToState(FetchItemsEvent event) async* {
    try {
      items = await TwoTPUtils.loadItemsFromFile(_filename);
      yield ChangedTOTPState(items);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapAddItemEventToState(AddItemEvent event) async* {
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
    try {
      items.remove(event.item);
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }

  Stream<TOTPState> mapReplaceItemEventToState(ReplaceItemEvent event) async* {
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
}

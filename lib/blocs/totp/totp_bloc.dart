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
      yield* mapAddItemsEventToState(event);
    } else if (event is RemoveItemEvent) {
      yield* mapRemoveItemsEventToState(event);
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

  Stream<TOTPState> mapAddItemsEventToState(AddItemEvent event) async* {
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

  Stream<TOTPState> mapRemoveItemsEventToState(RemoveItemEvent event) async* {
    try {
      items.remove(event.item);
      yield ChangedTOTPState(items);
      await TwoTPUtils.saveItemsToFile(items, _filename);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }
}

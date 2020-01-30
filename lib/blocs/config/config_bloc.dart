import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:twotp/utils/twotp_utils.dart';

import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  int darkModeOn = 0;

  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) async* {
    try {
      if(event is ChangeDarkMode) {
        TwoTPUtils.prefs.setInt("darkModeOn", event.value);
        yield InitConfigState();
      }
    } catch(error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  @override
  ConfigState get initialState => new UnitConfigState();
}
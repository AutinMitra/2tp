import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:twotp/utils/twotp_utils.dart';

import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {

  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) async* {
    if(event is ChangeConfigEvent) {
      yield* mapChangeConfigEventToState(event);
    } else if(event is FetchConfigEvent) {
      yield* mapFetchConfigEventToState(event);
    }
  }
  
  Stream<ConfigState> mapChangeConfigEventToState(ChangeConfigEvent event) async* {
    try {
      TwoTPUtils.prefs.setInt(TwoTPUtils.darkModePrefs, event.value);
      yield ChangedConfigState(event.value);
    } catch(error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  Stream<ConfigState> mapFetchConfigEventToState(FetchConfigEvent event) async* {
    try {
      int darkMode = TwoTPUtils.prefs.getInt(TwoTPUtils.darkModePrefs);
      yield ChangedConfigState(darkMode);
    } catch(error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  @override
  ConfigState get initialState => new UnitConfigState();
}
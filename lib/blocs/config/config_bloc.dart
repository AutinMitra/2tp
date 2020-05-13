import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:twotp/utils/twotp_utils.dart';

import 'config_event.dart';
import 'config_state.dart';

// Bloc for holding all the config events
class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) async* {
    if (event is ChangeConfigThemeEvent) {
      yield* mapChangeConfigEventToState(event);
    } else if (event is ChangeConfigFingerprintEvent) {
      yield* mapChangeConfigFingerprintEventToState(event);
    } else if(event is FetchConfigEvent) {
      yield* mapFetchConfigEventToState(event);
    }
  }

  Stream<ConfigState> mapChangeConfigEventToState(
      ChangeConfigThemeEvent event) async* {
    try {
      // Save settings in pref
      TwoTPUtils.prefs.setInt(TwoTPUtils.darkModePrefs, event.value);
      if (state is ChangedConfigState)
        yield (state as ChangedConfigState).copyWith(themeValue: event.value);
    } catch(error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  Stream<ConfigState> mapChangeConfigFingerprintEventToState(
      ChangeConfigFingerprintEvent event) async* {
    try {
      // Save settings in pref
      TwoTPUtils.prefs.setBool(TwoTPUtils.biometricsEnabled, event.enabled);
      if (state is ChangedConfigState)
        yield (state as ChangedConfigState).copyWith(
            biometricsEnabled: event.enabled);
    } catch (error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  Stream<ConfigState> mapFetchConfigEventToState(FetchConfigEvent event) async* {
    try {
      // Grab data from storage
      int darkMode = TwoTPUtils.prefs.getInt(TwoTPUtils.darkModePrefs);
      bool biometricsEnabled = TwoTPUtils.prefs.getBool(
          TwoTPUtils.biometricsEnabled) ?? false;
      yield ChangedConfigState(
          themeValue: darkMode, biometricsEnabled: biometricsEnabled);
    } catch(error, trace) {
      print('$error $trace');
      yield ErrorConfigState(error.message);
    }
  }

  @override
  ConfigState get initialState => new UnitConfigState();
}
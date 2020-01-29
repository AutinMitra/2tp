import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  @override
  // TODO: implement initialState
  ConfigState get initialState => null;

  @override
  Stream<ConfigState> mapEventToState(ConfigEvent event) {
    // TODO: implement mapEventToState
    return null;
  }

  @override
  // TODO: implement props
  List<Object> get props => null;

}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/totp/totp.dart';

class TOTPBloc extends Bloc<TOTPEvent, TOTPState> {
  List<TOTPItem> items = [];

  @override
  TOTPState get initialState => UnitTOTPState();

  @override
  Stream<TOTPState> mapEventToState(TOTPEvent event) {
    // TODO: implement mapEventToState
    return null;
  }

  Stream<TOTPState> mapFetchItemsEventToState(FetchItemsEvent event) async* {
    try {

    } catch (error, trace) {
      print('$error $trace');
      yield ErrorTOTPState(error.message);
    }
  }
}
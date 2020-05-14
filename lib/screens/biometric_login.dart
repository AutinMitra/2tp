import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_event.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/utils/biometric_utils.dart';

class BiometricLoginPage extends StatefulWidget {
  @override
  _BiometricLoginPageState createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _authenticateUser(context) async {
    if (await BiometricUtils.authenticate(
        reason: "Please authenticate to continue")) {
      // ignore: close_sinks
      final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);
      // ignore: close_sinks
      final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

      totpBloc.add(FetchItemsEvent());
      configBloc.add(FetchConfigEvent());
      Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    var buttonTextColor = (darkMode) ? Colors.black : Colors.white;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(LineIcons.user_lock_solid, size: 98),
                    SizedBox(height: 32),
                    Text(
                      "Please authenticate using biometrics",
                      style: TextStyles.appBarTitle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18),
                    RaisedButton(
                      onPressed: () {
                        _authenticateUser(context);
                      },
                      color: (darkMode) ? Colors.white : Colors.black,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(LineIcons.fingerprint_solid,
                              color: buttonTextColor),
                          SizedBox(width: 8),
                          Text("Authenticate",
                              style: TextStyles.buttonText
                                  .copyWith(color: buttonTextColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

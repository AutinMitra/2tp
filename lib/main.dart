import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_event.dart';
import 'package:twotp/blocs/config/config_state.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/screens/advanced_totp.dart';
import 'package:twotp/screens/biometric_login.dart';
import 'package:twotp/screens/home.dart';
import 'package:twotp/screens/qr_scan.dart';
import 'package:twotp/screens/settings.dart';
import 'package:twotp/theme/themes.dart';
import 'package:twotp/utils/twotp_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TwoTPUtils.prefs = await SharedPreferences.getInstance();
  runApp(MultiBlocProvider(providers: <BlocProvider>[
    BlocProvider<ConfigBloc>(create: (context) => ConfigBloc()),
    BlocProvider<TOTPBloc>(create: (context) => TOTPBloc()),
  ], child: TwoTP()));
}

class TwoTP extends StatefulWidget {
  @override
  _TwoTPState createState() => _TwoTPState();
}

class _TwoTPState extends State<TwoTP> {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);
    // ignore: close_sinks
    final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);

    bool biometricsEnabled = TwoTPUtils.prefs.getBool(
        TwoTPUtils.biometricsEnabled) ?? false;

    // Load all of the data from storage before going to home
    if (!biometricsEnabled) {
      totpBloc.add(FetchItemsEvent());
      configBloc.add(FetchConfigEvent());
    }

    // Configure theme settings
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      var themeVal;
      if (state is UnitConfigState)
        themeVal = TwoTPUtils.prefs.getInt(TwoTPUtils.darkModePrefs) ?? 2;
      else if (state is ChangedConfigState)
        themeVal = state.themeValue;

      ThemeData tLight = (themeVal == 1) ? Themes.darkMode : Themes.lightMode;
      ThemeData tDark = (themeVal == 0) ? Themes.lightMode : Themes.darkMode;

      // The final material app
      return MaterialApp(
        title: 'TwoTP',
        debugShowCheckedModeBanner: false,
        theme: tLight,
        darkTheme: tDark,
        initialRoute: biometricsEnabled ? '/auth' : '/',
        home: HomePage(),
        routes: {
          '/auth': (context) => BiometricLoginPage(),
          '/add/qr': (context) => QRScanPage(),
          '/add/advanced': (context) => AdvancedTOTPPage(),
          '/settings': (context) => SettingsPage(),
        },
      );
    });
  }
}

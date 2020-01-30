import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_state.dart';

import 'package:twotp/screens/home.dart';
import 'package:twotp/theme/themes.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/twotp_utils.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(TwoTP());
}

class TwoTP extends StatefulWidget {
  @override
  _TwoTPState createState() => _TwoTPState();
}

class _TwoTPState extends State<TwoTP> {
  TOTPItem sample = new TOTPItem("sdfqwefdsqwde", Uuid().v4(), accountName: "alice@bigCompany.com", issuer: "BigCompany");
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      var themeVal;
      if(state is UnitConfigState) 
        themeVal = TwoTPUtils.prefs.getInt(TwoTPUtils.darkModePrefs) ?? 2; 
      else if(state is ChangedConfigState) {
        themeVal = state.value;
      }
      ThemeData tLight = (themeVal == 1) ? Themes.darkMode : Themes.lightMode;
      ThemeData tDark = (themeVal == 0) ? Themes.lightMode : Themes.darkMode;
      return MaterialApp(
        title: 'TwoTP',
        debugShowCheckedModeBanner: false,
        theme: tLight,
        darkTheme: tDark,
        home: HomePage([sample]),
      );
    });
  }
}
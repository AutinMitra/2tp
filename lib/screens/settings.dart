import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_event.dart';
import 'package:twotp/blocs/config/config_state.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/utils/biometric_utils.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .scaffoldBackgroundColor
            .withOpacity(0.5),
        title: Text("Settings", style: TextStyles.appBarTitle),
        leading: Padding(
          padding: EdgeInsets.only(left: 14),
          child: IconButton(
            icon: Icon(LineIcons.angle_left_solid),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            children: [
              SizedBox(height: 84),
              _AppearancePanel(),
              SizedBox(height: 12),
              _SecurityPanel(),
            ]
        ),
      ),
    );
  }
}

// The appearance panel in settings - currently controls light/dark mode
class _AppearancePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      String mapThemeFromInt(int n) => n == 2 ? "System" : n == 1 ? "Dark" : "Light";

      List<int> dropList = [0, 1, 2];
      if(state is ChangedConfigState) {
        if (state.themeValue == 1)
          dropList = [1, 0, 2];
        else if (state.themeValue == 2) dropList = [2, 0, 1];
      }
      // ignore: close_sinks
      final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);
      int configTheme = (state is ChangedConfigState) ? state.themeValue : 2;
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(LineIcons.brush_solid),
              SizedBox(width: 8.0),
              Text("Appearance", style: TextStyles.settingsHeader),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Theme", style: TextStyles.settingsItemHeader),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                      hint: Text(mapThemeFromInt(configTheme)),
                      onChanged: (val) {
                        configBloc.add(ChangeConfigThemeEvent(val));
                      },
                      items: dropList.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(mapThemeFromInt(value)),
                        );
                      }).toList()
                  ),
                ),
              )
            ],
          )
        ],
      );
    });
  }
}

// The security panel in settings - currently controls fingerprint unlock
class _SecurityPanel extends StatelessWidget {

  void _onBiometricsChange(ConfigBloc configBloc, bool value) async {
    var authenticated = await BiometricUtils.authenticate(
        reason: "Please authenticate to continue");
    if (authenticated)
      configBloc.add(ChangeConfigFingerprintEvent(value));
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme
        .of(context)
        .brightness == Brightness.dark;

    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      // ignore: close_sinks
      final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);

      bool biometricsEnabled = (state is ChangedConfigState) ? state
          .biometricsEnabled : false;

      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(LineIcons.user_lock_solid),
              SizedBox(width: 8.0),
              Text("Security", style: TextStyles.settingsHeader),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Biometrics", style: TextStyles.settingsItemHeader),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Checkbox(
                    value: biometricsEnabled,
                    activeColor: (darkMode) ? Colors.white : Colors.black,
                    checkColor: (darkMode) ? Colors.black : Colors.white,
                    onChanged: (value) {
                      _onBiometricsChange(configBloc, value);
                    },
                  )
              ),
            ],
          )
        ],
      );
    });
  }
}
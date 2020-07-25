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
          ],
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
                child: _dropDownMenu(context, state)
              )
            ],
          )
        ],
      );
    });
  }

  /// [context] is the context of the Widget
  /// [state] is the Bloc State
  Widget _dropDownMenu(BuildContext context, ConfigState state) {
    var light = ChangeConfigThemeEvent.LIGHT;
    var dark = ChangeConfigThemeEvent.DARK;
    var system = ChangeConfigThemeEvent.SYSTEM;

    // Map the them value (int) to an actual name (String)
    Map<int, String> int2theme = {
      light: "Light",
      dark: "Dark",
      system: "System",
    };

    // Determine the order the list will show in the menu.
    List<int> dropList = [light, dark, system];
    if(state is ChangedConfigState) {
      if (state.themeValue == dark)
        dropList = [dark, light, system];
      else if (state.themeValue == system) dropList = [system, light, dark];
    }
    // ignore: close_sinks
    final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);
    int configTheme = (state is ChangedConfigState) ? state.themeValue : system;

    return  DropdownButtonHideUnderline(
      child: DropdownButton(
        elevation: 1,
        hint: Text(int2theme[configTheme]),
        onChanged: (val) {
          configBloc.add(ChangeConfigThemeEvent(val));
        },
        items: dropList.map((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(int2theme[value]),
          );
        }).toList(),
      ),
    );
  }
}

// The security panel in settings - currently controls fingerprint unlock.
class _SecurityPanel extends StatelessWidget {

  /// Shows the authentication dialog.
  /// [configBloc] is the Bloc containing configuration info
  /// [value] is whether biometrics are on or off
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

      // Check the biometrics status.
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
                ),
              ),
            ],
          )
        ],
      );
    });
  }
}
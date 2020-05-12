import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_event.dart';
import 'package:twotp/blocs/config/config_state.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/theme/text_styles.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    var style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: (Theme
            .of(context)
            .brightness == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Theme
            .of(context)
            .scaffoldBackgroundColor
    );
    SystemChrome.setSystemUIOverlayStyle(style);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: Scaffold(
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
                _AppearancePanel()
              ]
          ),
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
          SizedBox(height: 8),
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
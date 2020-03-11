import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
      (Theme
          .of(context)
          .brightness == Brightness.dark)
          ? Brightness.light
          : Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("Settings", style: TextStyles.appBarTitle),
        elevation: 1.0,
      ),
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          children: [
            SizedBox(height: 12),
            AppearancePanel()
          ]
        ),
      ),
    );
  }
}

class AppearancePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(builder: (context, state) {
      String mapThemeFromInt(int n) => n == 2 ? "System" : n == 1 ? "Dark" : "Light";

      List<int> dropList = [0, 1, 2];
      if(state is ChangedConfigState) {
        if(state.value == 1) dropList = [1, 0, 2];
        else if(state.value == 2) dropList = [2, 0, 1];
      }
      // ignore: close_sinks
      final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);
      int configTheme = (state is ChangedConfigState) ? state.value : 2;
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.palette),
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
                        configBloc.add(ChangeConfigEvent(val));
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      ),
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          children: <Widget>[
            SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(Icons.palette),
                SizedBox(width: 8.0),
                Text("Appearance", style: TextStyles.settingsHeader),
              ],
            )
          ],
        ),
      ),
    );
  }

}
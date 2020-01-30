import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:twotp/screens/home.dart';
import 'package:twotp/theme/themes.dart';
import 'package:twotp/totp/totp.dart';
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
    return MaterialApp(
      title: 'TwoTP',
      debugShowCheckedModeBanner: false,
      theme: Themes.lightMode,
      home: HomePage([sample]),
    );
  }
}

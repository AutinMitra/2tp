import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_state.dart';
import 'package:twotp/theme/palette.dart';

class PageWrapper extends StatefulWidget {
  final Widget child;

  PageWrapper({@required this.child}) : assert(child != null);

  @override
  _PageWrapperState createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper>
    with WidgetsBindingObserver {

  AppLifecycleState _lastState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ignore: close_sinks
    final ConfigBloc configBloc = BlocProvider.of<ConfigBloc>(context);
    if (state == AppLifecycleState.resumed &&
        _lastState == AppLifecycleState.paused &&
        configBloc.state is ChangedConfigState) {
      if ((configBloc.state as ChangedConfigState).biometricsEnabled) {
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    }
    _lastState = state;
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    var style = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: darkMode ? Palette.scDark : Palette.scLight,
      systemNavigationBarIconBrightness: darkMode ? Brightness.light : Brightness.dark,
    );

    SystemChrome.setSystemUIOverlayStyle(style);

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: style,
        child: widget.child
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/config/config_bloc.dart';
import 'package:twotp/blocs/config/config_state.dart';

class HandleAppLifecycle extends StatefulWidget {
  final Widget child;

  HandleAppLifecycle({@required this.child}) : assert(child != null);

  @override
  _HandleAppLifecycleState createState() => _HandleAppLifecycleState();
}

class _HandleAppLifecycleState extends State<HandleAppLifecycle>
    with WidgetsBindingObserver {
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
        configBloc.state is ChangedConfigState) {
      if ((configBloc.state as ChangedConfigState).biometricsEnabled) {
        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

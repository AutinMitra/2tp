import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/components/twotp_card.dart';
import 'package:twotp/theme/text_styles.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Theme
            .of(context)
            .backgroundColor,
        statusBarIconBrightness:
        (Theme
            .of(context)
            .brightness == Brightness.dark)
            ? Brightness.light
            : Brightness.dark,
      ),
      child: SafeArea(
        child: Scaffold(
            body: Column(
              children: <Widget>[
                _TOTPAppBar(),
                _TOTPList()
              ],
            )
        ),
      ),
    );
  }
}

class _TOTPAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: new Icon(Icons.settings),
            onPressed: () {},
          ),
          new Text("TwoTP", style: TextStyles.appBarTitle),
          IconButton(
            icon: new Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

}

class _TOTPList extends StatefulWidget {
  @override
  _TOTPListState createState() => _TOTPListState();
}

class _TOTPListState extends State<_TOTPList> {
  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    return BlocBuilder<TOTPBloc, TOTPState>(builder: (context, state) {
      if (state is UnitTOTPState) {
        totpBloc.add(FetchItemsEvent());
        return Container();
      } else if (state is ChangedTOTPState && state.items.length == 0) {
        // TODO: Replace with more fancy indicator, like an illustration
        return Expanded(child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Center(
                  child: Text("Nothing added", style: TextStyles.bodyInfoH1)),
              Center(child: Text(
                  "Click the + to add a token", style: TextStyles.bodyInfoH2)),
            ],
          ),
        ));
      } else if (state is ChangedTOTPState) {
        // TODO: Add fancy intro animation
        return ScrollConfiguration(
            behavior: NoOverScrollBehavior(),
            child: ListView(
              children: <Widget>[
                SizedBox(height: 12),
                for (var item in state.items)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
                    child: TwoTPCard(item, color: Color(0xFFF96F6F)),
                  )
              ],
            ));
      }
      return Text("An error occured");
    });
  }
}

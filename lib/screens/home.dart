import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/components/cards.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/theme/values.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark)
          ? Brightness.light
          : Brightness.dark,
    ));
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Palette.accent,
        elevation: 1.0,
        icon: Icon(Icons.add, color: Palette.primary),
        label: Text("Add Item", style: TextStyles.addItemButtonText),
        onPressed: () {
          Navigator.pushNamed(context, "/add/qr");
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Material(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.hardEdge,
        elevation: 8.0,
        child: Container(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: new Icon(Icons.settings),
                  onPressed: () {
                    Navigator.pushNamed(context, "/settings");
                  },
                ),
                IconButton(
                  icon: new Icon(Icons.search),
                  onPressed: () {
//                Navigator.pushNamed(context, '/add/qr');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: ScrollConfiguration(
          behavior: NoOverScrollBehavior(), child: _TOTPList()),
    );
  }
}

class _TwoTPAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("TwoTP", style: TextStyles.largeAppBarTitle),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {},
            )
          ],
        ),
    ));
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
        var screenHeight = MediaQuery.of(context).size.height;
        var spacer = (screenHeight - Values.navbarHeight) / 2 - 100;
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            _TwoTPAppBar(),
            Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: spacer),
                  Center(
                      child:
                          Text("Nothing added", style: TextStyles.bodyInfoH1)),
                  Center(
                    child: Text("Click the + to add a token",
                      style: TextStyles.bodyInfoH2
                    )
                  ),
                  SizedBox(height: spacer)
                ],
              ),
            ),
          ],
        );
      } else if (state is ChangedTOTPState) {
        // TODO: Add fancy intro animation
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            _TwoTPAppBar(),
            for (var item in state.items)
              Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
                child: Hero(tag: item.toString(), child: TwoTPCard(item)),
              )
          ],
        );
      } else {
        return Column(
            children: <Widget>[_TwoTPAppBar(), Text("An error occured")]);
      }
    });
  }
}

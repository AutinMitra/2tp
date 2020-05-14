import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/components/cards.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/components/scroll_views.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/theme/values.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    var style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkMode
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: Theme
            .of(context)
            .scaffoldBackgroundColor
    );
    SystemChrome.setSystemUIOverlayStyle(style);

    String logoSVGPath = "assets/twotp-logo.svg";
    final Widget logoSVG = SvgPicture.asset(
      logoSVGPath,
      color: (darkMode) ? Colors.white : Colors.black,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: style,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor:
          Theme
              .of(context)
              .scaffoldBackgroundColor
              .withOpacity(0.5),
          centerTitle: true,
            title: (_reordering)
                ? Text("Re-order Cards", style: TextStyles.appBarTitle)
                : SizedBox(child: logoSVG, height: 32, width: 32),
            actions: _getActions(_reordering)
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: (darkMode) ? Colors.white : Colors.black,
          elevation: 1.0,
          highlightElevation: 4.0,
          icon: Icon(
              Icons.add, color: (darkMode) ? Colors.black : Colors.white),
          label: Text("Add Item", style: TextStyles.addItemButtonText.copyWith(
              color: (darkMode) ? Colors.black : Colors.white
          )),
          onPressed: () {
            Navigator.pushNamed(context, "/add");
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: ScrollConfiguration(
          behavior: NoOverScrollBehavior(),
          child: _TOTPList(reordering: _reordering),
        ),
      ),
    );
  }

  List<Widget> _getActions(reordering) {
    if (!reordering) {
      return <Widget>[
        IconButton(
          icon: Icon(LineIcons.retweet_solid),
          onPressed: () {
            setState(() {
              _reordering = true;
            });
          },
        ),
        Padding(
          padding: EdgeInsets.only(right: 14),
          child: IconButton(
            icon: Icon(LineIcons.cog_solid),
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
          ),
        ),
      ];
    }
    return <Widget>[
      Padding(
        padding: EdgeInsets.only(right: 14),
        child: IconButton(
          icon: Icon(LineIcons.times_solid),
          onPressed: () {
            setState(() {
              _reordering = false;
            });
          },
        ),
      ),
    ];
  }
}

class _TOTPList extends StatefulWidget {
  final bool reordering;

  _TOTPList({@required this.reordering}) : assert(reordering != null);

  @override
  _TOTPListState createState() => _TOTPListState();
}

class _TOTPListState extends State<_TOTPList> {

  void onReorder(int from, int to) {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);
    totpBloc.add(MoveItemEvent(from, to));
  }

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
        var spacer = (screenHeight - ThemeValues.navbarHeight) / 2 - 100;
        return ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: spacer),
                  Center(
                      child:
                      Text("Nothing added", style: TextStyles.bodyInfoH1)),
                  Center(
                      child: Text("Click the + to add a token",
                          style: TextStyles.bodyInfoH2)),
                  SizedBox(height: spacer)
                ],
              ),
            ),
          ],
        );
      } else if (state is ChangedTOTPState) {
        // TODO: Add fancy intro animation
        return ImprovedReorderableListView(
          header: SizedBox(height: 84),
          scrollController: ScrollController(),
          enabled: widget.reordering,
          onReorder: onReorder,
          children: <Widget>[
            for (var item in state.items)
              ListTile(
                contentPadding: EdgeInsets.fromLTRB(24, 0, 24, 12),
                key: Key(item.toString()),
                title: Hero(
                  tag: item.toString(),
                  child: TwoTPCard(item, enableLongPress: !widget.reordering),
                ),
              )
          ],
        );
      }
      return Column(
        children: <Widget>[
          Text("An error occured"),
        ],
      );
    });
  }
}

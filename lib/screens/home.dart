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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _reordering = false;

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;

    AppBar appBar = _appBar();

    return Scaffold(
      appBar: appBar,
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: (darkMode) ? Colors.white : Colors.black,
        elevation: 1.0,
        highlightElevation: 4.0,
        icon: Icon(
            Icons.add, color: (darkMode) ? Colors.black : Colors.white),
        label: Text("Add Code", style: TextStyles.addItemButtonText.copyWith(
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
    );
  }

  /// The Home AppBar
  AppBar _appBar() {
    var darkMode = Theme.of(context).brightness == Brightness.dark;

    // Load the logo
    String logoSVGPath = "assets/twotp-logo.svg";
    final Widget logoSVG = SvgPicture.asset(
      logoSVGPath,
      color: (darkMode) ? Colors.white : Colors.black,
    );

    return AppBar(
        backgroundColor:
      Theme
          .of(context)
          .scaffoldBackgroundColor
          .withOpacity(0.5),
      centerTitle: true,
      title: (_reordering)
          ? Text("Reorder Cards", style: TextStyles.appBarTitle)
          : SizedBox(child: logoSVG, height: 32, width: 32),
      actions: _getActions(_reordering)
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
  /// Weather or not reordering is enabled
  final bool reordering;

  _TOTPList({@required this.reordering}) : assert(reordering != null);

  @override
  _TOTPListState createState() => _TOTPListState();
}

class _TOTPListState extends State<_TOTPList> {

  /// Callback for a reordering even in ImprovedReorderableListView.
  /// [from] is the index of item's original position.
  /// [to] is the index of item's final position.
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
        return _unitContent();
      } else if (state is ChangedTOTPState && state.items.length == 0) {
        return _noItemsContent();
      } else if (state is ChangedTOTPState) {
        return _hasCardsContent(state);
      }
      return Column(
        children: <Widget>[
          Text("An error occured"),
        ],
      );
    });
  }

  /// Content for home page when the cards have been uninitialized.
  Widget _unitContent() {
    return Container();
  }

  // Content for home page if there are no cards.
  Widget _noItemsContent() {
    // TODO: Replace with more fancy indicator, like an illustration
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
              child:
              Text("Nothing added", style: TextStyles.bodyInfoH1)),
          Center(
              child: Text("Click the + to add a token",
                  style: TextStyles.bodyInfoH2)),
        ],
      ),
    );
  }

  /// Home page content if the cards are loaded and exist
  /// [state] is the current TOTPState
  Widget _hasCardsContent(ChangedTOTPState state) {
    // TODO: Add fancy intro animation

    var topPadding = MediaQuery.of(context).padding.top;

    return ImprovedReorderableListView(
      padding: EdgeInsets.only(top: topPadding),
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
          ),
      ],
    );
  }
}

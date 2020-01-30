import 'package:flutter/material.dart';
import 'package:twotp/components/twotp_card.dart';
import 'package:twotp/totp/totp.dart';

class HomePage extends StatelessWidget {
  final List<TOTPItem> items;

  HomePage(this.items);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: new Text("TwoTP")
            ),
          ),
          _TOTPList(items)
        ]),
      ),
    );
  }
}

class _TOTPList extends StatefulWidget {
  final List<TOTPItem> items;

  _TOTPList(this.items);

  @override
  _TOTPListState createState() => _TOTPListState();
}

class _TOTPListState extends State<_TOTPList> {
  @override
  Widget build(BuildContext context) {
    if(widget.items == null) {
      return SliverToBoxAdapter(child: Text("Loading.. "));
    } else if(widget.items.length == 0) {
      return SliverToBoxAdapter(child: Center(child: Text("Nothing added...")));
    }
    return  SliverPadding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 28),
        sliver: SliverList(delegate: SliverChildBuilderDelegate(
                (context, index) {
              return Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
                child: TwoTPCard(widget.items[index], color: Color(0xFFF96F6F)),
              );
            },
            childCount: widget.items.length
        ))
    );
  }
}
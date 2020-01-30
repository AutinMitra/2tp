import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/color_utils.dart';

class TwoTPCard extends StatefulWidget {
  final TOTPItem totpItem;
  final Color color;
  TwoTPCard(this.totpItem, {this.color = const Color(0xFF9D9D9D)});
  @override
  _TwoTPCardState createState() => _TwoTPCardState();
}

class _TwoTPCardState extends State<TwoTPCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: ColorUtils.changeAlphaValue(widget.color, 0x70), blurRadius: 32.0, spreadRadius: 0),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          widget.totpItem.accountName != "" ? Text(
            widget.totpItem.accountName,
            style: TextStyle(fontSize: 14, color: Palette.textDark, fontWeight: FontWeight.w500),
          ) : Container(),
          SizedBox(
            height: 2,
          ),
          widget.totpItem.issuer != "" ? Text(
            widget.totpItem.issuer,
            style: TextStyle(fontSize: 20, color: Palette.textDark, fontWeight: FontWeight.w700),
          ) : Container(),
          SizedBox(
            height: 4,
          ),
          Text(
            "062 412",
            style: TextStyle(fontSize: 42, color: Palette.textDark, fontWeight: FontWeight.w900),
          ),
        ]),
    );
  }
}

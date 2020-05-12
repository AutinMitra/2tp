import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twotp/screens/edit_item.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/totp/totp.dart';

double _cardBorderRadius = 32;
int elevation = 2;
Color _spinnerColor = Palette.medBlue;
Color _spinnerBackgroundColor = Palette.scLight;
Color _shadowColor = Color(0x1A000000);
double _gapSize = 8;

class TwoTPCard extends StatefulWidget {
  final TOTPItem totpItem;

  TwoTPCard(this.totpItem);

  @override
  _TwoTPCardState createState() => _TwoTPCardState();
}

class _TwoTPCardState extends State<TwoTPCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  int get _secondsSinceEpoch =>
      (DateTime.now().millisecondsSinceEpoch / 1000).round();

  int get _timeLeft => widget.totpItem.period - _secondsSinceEpoch % widget.totpItem.period;

  double get _percentComplete =>
      (_secondsSinceEpoch % widget.totpItem.period) / widget.totpItem.period;

  String get _code =>
      widget.totpItem.generateCode(_secondsSinceEpoch, pretty: false);

  bool _warning = false;

  String _totpCode;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _totpCode = _code;    _animationController = AnimationController(
        duration: Duration(seconds: widget.totpItem.period),
        animationBehavior: AnimationBehavior.preserve,
        lowerBound: 0.0,
        upperBound: 1.00,
        vsync: this);
    _animationController.forward(from: _percentComplete);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        if(_timeLeft <= 10)
          setState(() {
            _warning = true;
          });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _totpCode = _code;
            _warning = false;
          });
          _animationController.repeat();
          _animationController.forward(from: _percentComplete);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    int digits = widget.totpItem.digits;
    List<Widget> numbers = [];
    int validDig = (digits == 6 || digits == 8) ? digits : 6;

    String code = _totpCode ?? _code;
    for (int i = 0; i < validDig; i++) {
      numbers.add(_NumberSlot(number: code[i], smallDigits: (digits > 6), warning: _warning));
      if (i == validDig / 2 - 1) numbers.add(SizedBox(width: _gapSize));
    }

    return Material(
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      clipBehavior: Clip.hardEdge,
      elevation: 16,
      shadowColor: _shadowColor,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: InkWell(
          onLongPress: () {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                    builder: (context) => EditItemPage(widget.totpItem)));
          },
          splashColor: Color(0x2ACFCFCF),
          highlightColor: Colors.transparent,
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardBorderRadius)),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _code));
            // TODO: Toast copy
          },
          child: Container(
            padding: EdgeInsets.all(24),
            child: Stack(
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      widget.totpItem.accountName != ""
                          ? Text(
                              widget.totpItem.accountName,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )
                          : Container(),
                      SizedBox(
                        height: 2,
                      ),
                      (widget.totpItem.issuer != "" &&
                              widget.totpItem.issuer != null)
                          ? Text(
                              widget.totpItem.issuer,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            )
                          : Container(),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: numbers
                      )
                    ]),
                Positioned(
                  right: 8,
                  top: 8,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) => Container(
                      width: 24,
                      height: 24,
                      margin: EdgeInsets.only(right: 4.0),
                      child: CircularProgressIndicator(
                        value: _animation.value,
                        strokeWidth: 5,
                        backgroundColor: _spinnerBackgroundColor,
                        valueColor: new AlwaysStoppedAnimation(
                            (_warning)
                                ? Palette.medRed
                                : _spinnerColor
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FakeTwoTPCard extends StatelessWidget {
  final int digits;
  final int period;
  final String algorithm;
  final String accountName;
  final String issuer;

  FakeTwoTPCard(
      {this.digits = 6,
      this.period = 30,
      this.algorithm = "SHA1",
      this.accountName = "",
      this.issuer = ""});

  List<Widget> _generateCode() {
    List<Widget> numbers = [];
    int validDig = (digits == 6 || digits == 8) ? digits : 6;
    for (int i = 1; i <= validDig; i++) {
      numbers.add(_NumberSlot(number: "$i", smallDigits: (digits > 6)));
      if (i == validDig / 2) numbers.add(SizedBox(width: _gapSize));
    }
    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      shadowColor: _shadowColor,
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: InkWell(
          splashColor: Color(0x2AFFFFFF),
          highlightColor: Colors.transparent,
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardBorderRadius)),
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(24),
            child: Stack(
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      accountName != "" && accountName != null
                          ? Text(
                              accountName,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            )
                          : Container(),
                      SizedBox(
                        height: 2,
                      ),
                      issuer != "" && issuer != null
                          ? Text(
                              issuer,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w700),
                            )
                          : Container(),
                      SizedBox(
                        height: 12,
                      ),
                      Row(children: _generateCode())
                    ]),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: EdgeInsets.only(right: 4.0),
                    child: CircularProgressIndicator(
                      value: 0.3,
                      strokeWidth: 5,
                      backgroundColor: _spinnerBackgroundColor,
                      valueColor: new AlwaysStoppedAnimation(_spinnerColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberSlot extends StatelessWidget {
  final bool warning, smallDigits;
  final String number;

  _NumberSlot(
      {this.warning: false, this.smallDigits: false, @required this.number})
      : assert(number != null);

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    var textColor = (warning)
        ? Palette.medRed
        : (darkMode) ? Palette.textDark : Palette.medBlue;
    var bgColor = (darkMode)
        ? Theme.of(context).scaffoldBackgroundColor
        : (warning) ? Palette.lightRed : Palette.lightBlue;

    return AnimatedContainer(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      margin: EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
      ),
      duration: Duration(milliseconds: 300),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 24, fontFamily: "JetBrainsMono"),
        ),
      ),
    );
  }
}

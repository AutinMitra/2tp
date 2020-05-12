import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twotp/screens/edit_item.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/totp/totp.dart';

double _cardBorderRadius = 32;
double _elevation = 16;
Color _spinnerColor = Palette.medBlue;
Color _shadowColor = Color(0x1A000000);
Color _splashColor = Color(0x2ACFCFCF);
double _gapSize = 8;

class TwoTPCard extends StatefulWidget {
  final TOTPItem totpItem;
  final bool enableLongPress;

  TwoTPCard(this.totpItem, {this.enableLongPress = true});

  @override
  _TwoTPCardState createState() => _TwoTPCardState();
}

class _TwoTPCardState extends State<TwoTPCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  int get _secondsSinceEpoch =>
      (DateTime.now().millisecondsSinceEpoch / 1000).round();

  int get _timeLeft =>
      widget.totpItem.period - _secondsSinceEpoch % widget.totpItem.period;

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
    _warning = _timeLeft <= 10;
    _totpCode = _code;
    _animationController = AnimationController(
        duration: Duration(seconds: widget.totpItem.period),
        animationBehavior: AnimationBehavior.preserve,
        lowerBound: 0.0,
        upperBound: 1.00,
        vsync: this);
    _animationController.forward(from: _percentComplete);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        if (_timeLeft <= 10 && !_warning)
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

  Widget _cardContent() {
    var darkMode = (Theme
        .of(context)
        .brightness == Brightness.dark);

    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
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
              _getCode(),
            ],
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) =>
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(right: 4.0),
                  child: CircularProgressIndicator(
                    value: _animation.value,
                    strokeWidth: 5,
                    backgroundColor: (darkMode) ? Color(0x3AFFFFFF) : Palette
                        .scLight,
                    valueColor: new AlwaysStoppedAnimation(
                        (_warning) ? Palette.medRed : _spinnerColor),
                  ),
                ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = (Theme
        .of(context)
        .brightness == Brightness.dark);

    return Material(
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      clipBehavior: Clip.hardEdge,
      elevation: _elevation,
      shadowColor: _shadowColor,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme
              .of(context)
              .backgroundColor,
        ),
        child: InkWell(
          onLongPress: (widget.enableLongPress) ? () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => EditItemPage(widget.totpItem),
              ),
            );
          } : null,
          splashColor: _splashColor,
          highlightColor: Colors.transparent,
          customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardBorderRadius)),
          onTap: () {
            Clipboard.setData(ClipboardData(text: _code));
            // TODO: Toast copy
          },
          child: Container(
              padding: EdgeInsets.all(24),
              child: _cardContent()
          ),
        ),
      ),
    );
  }

  Widget _getCode() {
    int digits = widget.totpItem.digits;
    List<Widget> numbers = [];
    int validDig = (digits == 6 || digits == 8) ? digits : 6;

    String code = _totpCode ?? _code;
    for (int i = 0; i < validDig; i++) {
      numbers.add(_NumberSlot(
          number: code[i], smallDigits: (digits > 6), warning: _warning));
      if (i == validDig / 2 - 1) numbers.add(SizedBox(width: _gapSize));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: numbers,
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

  Widget _getCode() {
    List<Widget> numbers = [];
    int validDig = (digits == 6 || digits == 8) ? digits : 6;
    for (int i = 1; i <= validDig; i++) {
      numbers.add(_NumberSlot(number: "$i", smallDigits: (digits >= 8)));
      if (i == validDig / 2) numbers.add(SizedBox(width: _gapSize));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: numbers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = (Theme
        .of(context)
        .brightness == Brightness.dark);

    return Material(
      elevation: _elevation,
      shadowColor: _shadowColor,
      borderRadius: BorderRadius.circular(_cardBorderRadius),
      clipBehavior: Clip.hardEdge,
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
        ),
        child: InkWell(
          splashColor: _splashColor,
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
                    _getCode(),
                  ],
                ),
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
                      backgroundColor: (darkMode) ? Color(0x3AFFFFFF) : Palette
                          .scLight,
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
    double digitSize = (smallDigits) ? 16 : 24;
    double horizontalPadding = (smallDigits) ? 8 : 10;
    double horizontalSpacing = (smallDigits) ? 3 : 6;

    return AnimatedContainer(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
      margin: EdgeInsets.only(right: horizontalSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
      ),
      duration: Duration(milliseconds: 300),
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: digitSize,
              fontFamily: "JetBrainsMono"),
          child: Text(
            number,
          ),
        ),
      ),
    );
  }
}

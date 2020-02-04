import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/color_utils.dart';

class TwoTPCard extends StatefulWidget {
  final TOTPItem totpItem;
  final Color color;

  TwoTPCard(this.totpItem, {this.color = Palette.defaultCardColor});

  @override
  _TwoTPCardState createState() => _TwoTPCardState();
}

class _TwoTPCardState extends State<TwoTPCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  int get _secondsSinceEpoch =>
      (DateTime
          .now()
          .millisecondsSinceEpoch / 1000).round();

  double get _percentComplete =>
      (_secondsSinceEpoch % widget.totpItem.period) / widget.totpItem.period;

  String get _code =>
      widget.totpItem.generateCode(_secondsSinceEpoch, pretty: true);

  String _totpCode;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _totpCode = _code;
    _animationController = AnimationController(
        duration: Duration(seconds: widget.totpItem.period),
        animationBehavior: AnimationBehavior.preserve,
        lowerBound: 0.0,
        upperBound: 1.00,
        vsync: this);
    _animationController.forward(from: _percentComplete);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _totpCode = _code;
          });
          _animationController.repeat();
          _animationController.forward(from: _percentComplete);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: ColorUtils.changeAlphaValue(widget.color, 0x70),
              blurRadius: 16.0,
              spreadRadius: 2,
              offset: Offset(
                  0, 5
              )
          ),
          BoxShadow(
              color: ColorUtils.changeAlphaValue(Colors.black, 0x10),
              blurRadius: 16.0,
              spreadRadius: 2,
              offset: Offset(
                  0, 5
              )
          ),
        ],
      ),
      child: InkWell(
        splashColor: Color(0x2AFFFFFF),
        highlightColor: Colors.transparent,
        customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32)),
        onTap: () {
          Clipboard.setData(ClipboardData(text: _code));
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
                          fontSize: 14,
                          color: Palette.textDark,
                          fontWeight: FontWeight.w500),
                    )
                        : Container(),
                    SizedBox(
                      height: 2,
                    ),
                    widget.totpItem.issuer != ""
                        ? Text(
                      widget.totpItem.issuer,
                      style: TextStyle(
                          fontSize: 20,
                          color: Palette.textDark,
                          fontWeight: FontWeight.w700),
                    )
                        : Container(),
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      _totpCode ?? _code,
                      style: TextStyle(
                          fontSize: 42,
                          color: Palette.textDark,
                          fontWeight: FontWeight.w900),
                    ),
                  ]),
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
                          backgroundColor: Color(0x3AFFFFFF),
                          valueColor: new AlwaysStoppedAnimation(
                              Palette.textDark),
                        ),
                      ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

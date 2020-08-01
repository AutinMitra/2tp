import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:twotp/screens/edit_item.dart';
import 'package:twotp/theme/card_colors.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/totp/totp.dart';

// Some constants shared between the classes
double _cardBorderRadius = 32;
Color _spinnerColor = Colors.black;
Color _spinnerColorDark = Colors.white;
Color _splashColor = Color(0x2ACFCFCF);
Color _spinnerBg = Color(0x30000000);
Color _spinnerBgDark = Color(0x30FFFFFF);
double _gapSize = 8;

/// An actual, working Card producing correct codes
class TwoTPCard extends StatefulWidget {
  /// [totpItem] is a TOTPItem that is used by the card to display codes
  final TOTPItem totpItem;

  /// [enableLongPress] enables long pressing to open card-specific options,
  /// and is by default true
  final bool enableLongPress;

  TwoTPCard(this.totpItem, {
      this.enableLongPress = true,
    });

  @override
  _TwoTPCardState createState() => _TwoTPCardState();
}

class _TwoTPCardState extends State<TwoTPCard>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;

  double get _secondsSinceEpoch =>
      DateTime.now().millisecondsSinceEpoch / 1000;

  int get _timeLeft =>
      widget.totpItem.period - _secondsSinceEpoch ~/ 1 % widget.totpItem.period;

  double get _percentComplete =>
      (_secondsSinceEpoch % widget.totpItem.period) / widget.totpItem.period;

  String get _code =>
      widget.totpItem.generateCode(_secondsSinceEpoch ~/ 1, pretty: false);

  bool _warning = false;

  String _totpCode;

  // UI specific vars
  /// Whether the user is pressing the card
  bool pressed = false;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _warning = _timeLeft <= 5;
    _totpCode = _code;

    // Handle progression animation
    _animationController = AnimationController(
        duration: Duration(seconds: widget.totpItem.period),
        animationBehavior: AnimationBehavior.preserve,
        lowerBound: 0.0,
        upperBound: 1.00,
        vsync: this);
    _animationController.forward(from: _percentComplete);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController)
      ..addListener(() {
        // Indicate a warning when there is 5 seconds let
        if (!_warning && _timeLeft <= 5)
          setState(() {
            _warning = true;
          });
      })
      ..addStatusListener((AnimationStatus status) {
        // When the code duration is over, regenerate the card and update state
        // This forces the card to redraw for a new code
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _code));
  }

  @override
  Widget build(BuildContext context) {
    final cardItem = ({Widget child}) => Styled.widget(child: child)
      .borderRadius(all: _cardBorderRadius)
      .ripple(
        highlightColor: Colors.transparent,
        splashColor: _splashColor
      )
      .backgroundColor(widget.totpItem.colorConfig.color, animate: true)
      .clipRRect(all: _cardBorderRadius)
      .borderRadius(all: _cardBorderRadius, animate: true)
      .elevation(
        pressed ? 0 : 20,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        shadowColor: widget.totpItem.colorConfig.color.withOpacity(0.3)
      )
      .gestures(
        onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
        onTap: () => _copyToClipboard(),
        onLongPress: (widget.enableLongPress) ? () {
          HapticFeedback.heavyImpact();
          Navigator.pushNamed(
              context,
              '/edit',
              arguments: EditItemArguments(widget.totpItem)
          );
        } : null,
      )
      .scale(pressed ? 0.95 : 1.0, animate: true)
      .animate(Duration(milliseconds: 150), Curves.easeOut);

    var textColor = widget.totpItem.colorConfig.dark
      ? Colors.white
      : Colors.black;

    return cardItem(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: _cardContent()
        ),
      ),
    );
  }

  // Get the current code
  Widget _getCode() {
    int digits = widget.totpItem.digits;
    List<Widget> numbers = [];
    int validDig = (digits == 6 || digits == 8) ? digits : 6;

    // Get the code
    String code = _totpCode ?? _code;
    // Convert the code to Widgets
    for (int i = 0; i < validDig; i++) {
      numbers.add(_NumberSlot(
        number: code[i],
        smallDigits: (digits > 6),
        warning: _warning,
        dark: widget.totpItem.colorConfig.dark,
      ));
      if (i == validDig / 2 - 1) numbers.add(SizedBox(width: _gapSize));
    }

    // Horizontal scroll view to prevent overflow on small devices
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: numbers,
      ),
    );
  }

  // The inner content of the card
  Widget _cardContent() {
    return Stack(
      children: <Widget>[
        SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if(widget.totpItem.accountName != "")
                Text(
                  widget.totpItem.accountName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              SizedBox(
                height: 2,
              ),
              if (widget.totpItem.issuer != "" &&
                  widget.totpItem.issuer != null)
                Text(
                  widget.totpItem.issuer,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              SizedBox(
                height: 12,
              ),
              _getCode(),
            ],
          ),
        ),
        _animatedCircle(),
      ],
    );
  }

  /// Creates an animated circle showing the duration left
  Widget _animatedCircle() {
    var dark = widget.totpItem.colorConfig.dark;

    return Positioned(
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
              backgroundColor: (dark)
                  ? _spinnerBgDark
                  : _spinnerBg,
              valueColor: new AlwaysStoppedAnimation(
                  (_warning) ? Palette.medRed :
                    dark ? _spinnerColorDark : _spinnerColor
              ),
            ),
          ),
      ),
    );
  }
}

class FakeTwoTPCard extends StatefulWidget {
  /// [digits] is the length of the code
  final int digits;

  /// [period] is how long each code will last
  final int period;

  /// [algorithm] is the algorithm being used
  final String algorithm;

  /// [accountName] is the label, or user of the code
  final String accountName;

  /// [issuer] is the provider of the code
  final String issuer;

  /// [colorConfig] is the background color of the card
  final CardColorConfig colorConfig;


  FakeTwoTPCard(
      {
        this.digits = 6,
        this.period = 30,
        this.algorithm = "SHA1",
        this.accountName = "",
        this.issuer = "",
        this.colorConfig = CardColors.defaultConfig,
      });

  @override
  _FakeTwoTPCardState createState() => _FakeTwoTPCardState();

}

// A fake/dummy card that produces an output similar to that of TwoTPCard
// Used for visualization
class _FakeTwoTPCardState extends State<FakeTwoTPCard> {
  bool pressed = false;

  /// Gets the current TOTPItem and returns a Widget displaying the TOTP numbers
  Widget _getCode() {
    var digits = widget.digits;
    List<Widget> numbers = [];
    // Check for the correct number of digits
    int validDig = (digits == 6 || digits == 8) ? digits : 6;

    // Add all the numbers as UI components, plus a space in the middle
    for (int i = 1; i <= validDig; i++) {
      numbers.add(_NumberSlot(
        number: "$i",
        smallDigits: (digits >= 8),
        dark: widget.colorConfig.dark,
      ));
      if (i == validDig / 2) numbers.add(SizedBox(width: _gapSize));
    }

    // Sideways scrolling view in case there is horizontal overflow on smaller screens
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: numbers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardItem = ({Widget child}) => Styled.widget(child: child)
        .borderRadius(all: _cardBorderRadius)
        .ripple(
          highlightColor: Colors.transparent,
          splashColor: _splashColor
        )
        .backgroundColor(widget.colorConfig.color, animate: true)
        .clipRRect(all: _cardBorderRadius)
        .borderRadius(all: _cardBorderRadius, animate: true)
        .elevation(
          pressed ? 0 : 20,
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        shadowColor: widget.colorConfig.color.withOpacity(0.3)
        )
        .gestures(
          onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
        )
        .scale(pressed ? 0.95 : 1.0, animate: true)
        .animate(Duration(milliseconds: 150), Curves.easeOut);

    var textColor = widget.colorConfig.dark
        ? Colors.white
        : Colors.black;

    return cardItem(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: _cardContent()
        ),
      ),
    );
  }

  Widget _cardContent() {
    var accountName = widget.accountName;
    var issuer = widget.issuer;

    return Stack(
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if(accountName != "" && accountName != null)
              Text(
                accountName,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            SizedBox(
              height: 2,
            ),
            if(issuer != "" && issuer != null)
              Text(
                issuer,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            SizedBox(
              height: 12,
            ),
            _getCode(),
          ],
        ),
        _animatedCircle(),
      ],
    );
  }

  Widget _animatedCircle() {
    var dark = widget.colorConfig.dark;

    return Positioned(
      right: 8,
      top: 8,
      child: Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.only(right: 4.0),
        child: CircularProgressIndicator(
          value: 0.3,
          strokeWidth: 5,
          backgroundColor: (dark)
              ? _spinnerBgDark
              : _spinnerBg,
          valueColor: new AlwaysStoppedAnimation(dark ? _spinnerColorDark : _spinnerColor),
        ),
      ),
    );
  }
}

// A number + background for a code
class _NumberSlot extends StatelessWidget {
  // [warning] enables red "warning" colors for the numbers
  final bool warning;

  // [smallDigits] is so 8-digit codes fit inside a card
  final bool smallDigits;

  // [number] is a single one character
  final String number;

  final bool dark;

  _NumberSlot(
      {this.warning: false, this.smallDigits: false, @required this.dark, @required this.number})
      : assert(number != null),
        assert(dark != null),
        assert(number.length == 1);

  @override
  Widget build(BuildContext context) {
    var appModeIsDark = Theme.of(context).brightness == Brightness.dark;
    var textColor = warning ? Palette.medRed : dark ? Colors.white : Colors.black;
    // Choose the current background color based on brightness
    var bgColor = (dark) ? Color(0x40000000) : Color(0x40FFFFFF);
    if(warning) {
      bgColor = (appModeIsDark) ? Palette.scDark : Palette.lightRed;
    }

    // Choose the digit size based on [smallDigits]
    double digitSize = (smallDigits) ? 20 : 24;
    double horizontalPadding = (smallDigits) ? 8 : 10;
    double horizontalSpacing = (smallDigits) ? 3 : 6;

    // Container is animated for smoothness
    return AnimatedContainer(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
      margin: EdgeInsets.only(right: horizontalSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
      ),
      duration: Duration(milliseconds: 300),
      child: Center(
        // Animated for color changes
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: digitSize,
            fontFamily: "JetBrainsMono",
          ),
          child: Text(
            number,
          ),
        ),
      ),
    );
  }
}

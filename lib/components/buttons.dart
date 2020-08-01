import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:styled_widget/styled_widget.dart';

class CustomRaisedButton extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color textColor;
  final double elevation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  CustomRaisedButton({
    @required this.child,
    this.color = const Color(0xFF000000),
    this.textColor = const Color(0xFFFFFFFF),
    this.elevation = 8.0,
    this.onTap,
    this.onLongPress
  }) : assert(child != null);

  @override
  _CustomRaisedButtonState createState() => _CustomRaisedButtonState();
}

class _CustomRaisedButtonState extends State<CustomRaisedButton> {
  bool pressed = false;
  
  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;

    final cardItem = ({Widget child}) => Styled.widget(child: child)
      .height(44)
      .borderRadius(all: 12)
      .ripple(
        highlightColor: Colors.transparent,
        splashColor: darkMode ? Color(0x30000000) : Color(0x30FFFFFF)
      )
      .backgroundColor(widget.color, animate: true)
      .clipRRect(all: 12)
      .borderRadius(all: 12, animate: true)
      .elevation(
        pressed ? 0 : widget.elevation,
        borderRadius: BorderRadius.circular(12),
        shadowColor: widget.color.withOpacity(0.4)
      )
      .gestures(
        onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      )
      .scale(pressed ? 0.95 : 1.0, animate: true)
      .animate(Duration(milliseconds: 150), Curves.easeOut);

    return cardItem(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: DefaultTextStyle(
          style: TextStyle(color: widget.textColor),
          child: Center(child: widget.child)
        ),
      ),
    );
  }
}

class CustomIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double elevation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  CustomIconButton({
    @required this.icon,
    this.color = const Color(0xFF000000),
    this.iconColor = const Color(0xFFFFFFFF),
    this.elevation = 8.0,
    this.onTap,
    this.onLongPress
  }) : assert(icon != null);

  @override
  _CustomIconButtonState createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final cardItem = ({Widget child}) => Styled.widget(child: child)
      .height(58)
      .width(58)
      .borderRadius(all: 12)
      .ripple(
        highlightColor: Colors.transparent,
      )
      .backgroundColor(widget.color, animate: true)
      .clipRRect(all: 12)
      .borderRadius(all: 12, animate: true)
      .elevation(
          pressed ? 0 : widget.elevation,
          borderRadius: BorderRadius.circular(12),
          shadowColor: widget.color.withOpacity(0.4)
      )
      .gestures(
        onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      )
      .scale(pressed ? 0.95 : 1.0, animate: true)
      .animate(Duration(milliseconds: 150), Curves.easeOut);

    return cardItem(
      child: Center(
        child: Icon(
          widget.icon,
          size: 28,
          color: widget.iconColor,
        ),
      ),
    );
  }
}
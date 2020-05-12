import 'package:flutter/material.dart';

// Prevents the "overscroll" effect in Android
class NoOverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

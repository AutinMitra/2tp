import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';

class ToastMessage extends StatelessWidget {
  final String message;
  final bool error;

  ToastMessage({this.message, this.error = false})
  : assert(message != null);

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(
          maxHeight: 48,
          maxWidth: 152
        ),
        decoration: BoxDecoration(
          color: (!error) ? Palette.lightGreen : Palette.lightRed,
          borderRadius: BorderRadius.circular(12.0)
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Center(
          child: Text(message,
            style: TextStyles.toastText.copyWith(color: Colors.black)
          )
        )
    );
  }
}

import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';

class AdvancedFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function validator;
  final Function onChanged;
  final String hintText;
  final String labelText;
  final bool obscureText;

  AdvancedFormTextField(
      {this.controller,
      this.validator,
      this.onChanged,
      this.hintText = "",
      this.labelText,
      this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
        validator: validator,
        cursorColor: (darkMode) ? Palette.textDark : Palette.textLight,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            filled: true,
            border: UnderlineInputBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0)))),
        onChanged: onChanged);
  }
}

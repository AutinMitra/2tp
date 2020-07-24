import 'package:flutter/material.dart';
import 'package:twotp/theme/palette.dart';

// Text Field to be used by multiple forms in TwoTP
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
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.transparent
              ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: Colors.transparent
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),

      ),
        onChanged: onChanged);
  }
}

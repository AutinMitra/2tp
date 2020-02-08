import 'package:base32/base32.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/color_utils.dart';
import 'package:uuid/uuid.dart';

class AdvancedTOTPPage extends StatefulWidget {
  @override
  _AdvancedTOTPPageState createState() => _AdvancedTOTPPageState();
}

class _AdvancedTOTPPageState extends State<AdvancedTOTPPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _secretController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _issuerController = TextEditingController();
  TextEditingController _digitsController = TextEditingController() ?? 6;
  TextEditingController _periodController = TextEditingController() ?? 30;
  TextEditingController _algorithmController =
      TextEditingController() ?? "SHA1";

  _FakeTwoTPCard _card;

  int _validateInt(String val) {
    try {
      return int.parse(val);
    } catch (e) {
      return null;
    }
  }

  String _validateString(String val) {
    if (val == "" || val == null) return null;
    return val;
  }

  Widget _generateCard() {
    var accountName =
        _validateString(_accountNameController.text) ?? "Account Name";
    var issuer = _validateString(_issuerController.text);
    var digits = _validateInt(_digitsController.text) ?? 6;
    var period = _validateInt(_periodController.text) ?? 30;
    var algorithm = _validateString(_algorithmController.text) ?? "SHA1";

    setState(() {
      _card = _FakeTwoTPCard(
          digits: digits,
          period: period,
          algorithm: algorithm,
          accountName: accountName,
          issuer: issuer);
    });
    return _card;
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    _generateCard();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: (Theme
          .of(context)
          .brightness == Brightness.dark)
          ? Brightness.light
          : Brightness.dark,
    ));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        title: Text("Manual Input", style: TextStyles.appBarTitle),
      ),
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            children: <Widget>[
              SizedBox(height: 16),
              _card ?? _FakeTwoTPCard(),
              SizedBox(height: 32),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isEmpty) return 'Required';
                  try {
                    base32.decode(value);
                  } catch (e) {
                    return "Invalid Secret";
                  }
                  return null;
                },
                controller: _secretController,
                hintText: "Secret*",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isEmpty) return "Required";
                  return null;
                },
                controller: _accountNameController,
                hintText: "Account Name*",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                controller: _issuerController,
                hintText: "Issuer",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isNotEmpty) if (value.toString() != "6" &&
                      value != "8")
                    return "Invalid digits, only 6 or 8 allowed";
                  return null;
                },
                controller: _digitsController,
                hintText: "Digits (default: 6)",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isNotEmpty) {
                    try {
                      if (int.parse(value) <= 0)
                        return "Period must be greater than 0";
                    } catch (e) {
                      return "Only integer values allowed";
                    }
                  }
                  return null;
                },
                controller: _periodController,
                hintText: "Period (default: 30)",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isNotEmpty &&
                      (value != "SHA1" ||
                          value != "SHA256" ||
                          value != "SHA512"))
                    return "Only SHA1, SHA256, or SHA512 is available";
                  return null;
                },
                controller: _algorithmController,
                hintText: "Algorithm (default: SHA1)",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              RaisedButton(
                  color: Palette.primary,
                  textColor: Colors.white,
                  child: Text("Add Item", style: TextStyles.buttonText),
                  onPressed: () {
                    // ignore: close_sinks
                    final TOTPBloc totpBloc =
                    BlocProvider.of<TOTPBloc>(context);

                    if (_formKey.currentState.validate()) {
                      var secret = _validateString(_secretController.text);
                      var accountName =
                      _validateString(_accountNameController.text);
                      var issuer = _validateString(_issuerController.text);
                      var digits = _validateInt(_digitsController.text) ?? 6;
                      var period = _validateInt(_periodController.text) ?? 30;
                      var algorithm =
                          _validateString(_algorithmController.text) ?? "SHA1";
                      TOTPItem item = TOTPItem(secret, Uuid().v4(),
                          accountName: accountName,
                          issuer: issuer,
                          digits: digits,
                          period: period,
                          algorithm: algorithm);
                      totpBloc.add(AddItemEvent(item));
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (r) => false);
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class _FakeTwoTPCard extends StatelessWidget {
  final int digits;
  final int period;
  final String algorithm;
  final String accountName;
  final String issuer;
  final Color color;

  _FakeTwoTPCard({this.digits = 6,
    this.period = 30,
    this.algorithm = "SHA1",
    this.accountName = "",
    this.issuer = "",
    this.color = Palette.defaultCardColor});

  String _generateCode() {
    String s = "";
    int validDig = (digits == 6 || digits == 8) ? digits : 6;
    for (int i = 1; i <= validDig; i++) {
      s += i.toString();
    }
    s = TOTP.formatOTP(s);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
              color: ColorUtils.changeAlphaValue(color, 0x70),
              blurRadius: 16.0,
              spreadRadius: 2,
              offset: Offset(0, 5)),
          BoxShadow(
              color: ColorUtils.changeAlphaValue(Colors.black, 0x10),
              blurRadius: 16.0,
              spreadRadius: 2,
              offset: Offset(0, 5)),
        ],
      ),
      child: InkWell(
        splashColor: Color(0x2AFFFFFF),
        highlightColor: Colors.transparent,
        customBorder:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
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
                          fontSize: 14,
                          color: Palette.textDark,
                          fontWeight: FontWeight.w500),
                    )
                        : Container(),
                    SizedBox(
                      height: 2,
                    ),
                    issuer != "" && issuer != null
                        ? Text(
                      issuer,
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
                      _generateCode(),
                      style: TextStyle(
                          fontSize: 42,
                          color: Palette.textDark,
                          fontWeight: FontWeight.w900),
                    ),
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
                    backgroundColor: Color(0x3AFFFFFF),
                    valueColor: new AlwaysStoppedAnimation(Palette.textDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdvancedFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final Function validator;
  final Function onChanged;
  final String hintText;

  AdvancedFormTextField(
      {this.controller, this.validator, this.onChanged, this.hintText = ""});

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    return TextFormField(
        validator: validator,
        cursorColor: (darkMode) ? Palette.textDark : Palette.textLight,
        controller: controller,
        decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            border: UnderlineInputBorder(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0))
            )
        ),
        onChanged: onChanged
    );
  }
}
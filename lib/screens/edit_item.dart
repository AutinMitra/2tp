import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/components/cards.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/components/text_fields.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/totp/totp.dart';

class EditItemPage extends StatefulWidget {
  final TOTPItem totpItem;

  EditItemPage(this.totpItem);

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  TextEditingController _secretController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _issuerController = TextEditingController();
  TextEditingController _digitsController = TextEditingController() ?? 6;
  TextEditingController _periodController = TextEditingController() ?? 30;
  TextEditingController _algorithmController =
      TextEditingController() ?? "SHA1";

  FakeTwoTPCard _card;

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
    var accountName = _validateString(_accountNameController.text) ??
        widget.totpItem.accountName;
    var issuer =
        _validateString(_issuerController.text) ?? widget.totpItem.issuer;
    var digits = _validateInt(_digitsController.text) ?? widget.totpItem.digits;
    var period = _validateInt(_periodController.text) ?? widget.totpItem.period;
    var algorithm =
        _validateString(_algorithmController.text) ?? widget.totpItem.algorithm;

    setState(() {
      _card = FakeTwoTPCard(
          digits: digits,
          period: period,
          algorithm: algorithm,
          accountName: accountName,
          issuer: issuer);
    });
    return _card;
  }

  void remove(BuildContext context) {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    // TODO: Are you sure? + toast
    totpBloc.add(RemoveItemEvent(widget.totpItem));
    Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);
  }

  void save(BuildContext context) {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    TOTPItem item = widget.totpItem;
    if (_formKey.currentState.validate()) {
      var secret = _validateString(_secretController.text) ?? item.secret;
      var accountName =
          _validateString(_accountNameController.text) ?? item.accountName;
      var issuer = _validateString(_issuerController.text) ?? item.issuer;
      var digits = _validateInt(_digitsController.text) ?? item.digits;
      var period = _validateInt(_periodController.text) ?? item.period;
      var algorithm =
          _validateString(_algorithmController.text) ?? item.algorithm;
      TOTPItem replacement = TOTPItem(secret, item.id,
          accountName: accountName,
          issuer: issuer,
          digits: digits,
          period: period,
          algorithm: algorithm);
      totpBloc.add(ReplaceItemEvent(item, replacement));
      Navigator.pushNamedAndRemoveUntil(context, "/", (r) => false);

      // TODO: Toast/Confirmation
    }
  }

  @override
  void initState() {
    super.initState();
    TOTPItem item = widget.totpItem;
    _secretController.text = item.secret;
    _accountNameController.text = item.accountName;
    _issuerController.text = item.issuer;
    _digitsController.text = item.digits.toString();
    _periodController.text = item.period.toString();
    _algorithmController.text = item.algorithm.toString();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark)
          ? Brightness.light
          : Brightness.dark,
    ));

    return new Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).backgroundColor,
        title: Text("Edit Item", style: TextStyles.appBarTitle),
      ),
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 18),
            children: <Widget>[
              SizedBox(height: 8),
              Hero(tag: widget.totpItem.toString(), child: _generateCard()),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: RaisedButton(
                        color: Palette.darkRed,
                        textColor: Colors.white,
                        child: Text("Remove", style: TextStyles.buttonText),
                        onPressed: () {
                          remove(context);
                        }),
                  ),
                  SizedBox(width: 12.0),
                  Expanded(
                    child: RaisedButton(
                        color: Palette.primary,
                        textColor: Colors.white,
                        child: Text("Save", style: TextStyles.buttonText),
                        onPressed: () {
                          save(context);
                        }),
                  ),
                ],
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                obscureText: true,
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
                labelText: "Secret*",
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
                labelText: "Account Name*",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                controller: _issuerController,
                labelText: "Issuer",
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
                labelText: "Digits",
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
                labelText: "Period",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
              AdvancedFormTextField(
                validator: (value) {
                  if (value.isNotEmpty &&
                      (value != "SHA1" &&
                          value != "SHA256" &&
                          value != "SHA512"))
                    return "Only SHA1, SHA256, or SHA512 is available";
                  return null;
                },
                controller: _algorithmController,
                labelText: "Algorithm",
                onChanged: (_) {
                  _generateCard();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

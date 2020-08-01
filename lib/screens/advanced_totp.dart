import 'package:base32/base32.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/components/buttons.dart';
import 'package:twotp/components/cards.dart';
import 'package:twotp/components/scroll_behaviors.dart';
import 'package:twotp/components/text_fields.dart';
import 'package:twotp/theme/card_colors.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/totp/totp.dart';
import 'package:uuid/uuid.dart';

class AdvancedTOTPPage extends StatefulWidget {
  @override
  _AdvancedTOTPPageState createState() => _AdvancedTOTPPageState();
}

class _AdvancedTOTPPageState extends State<AdvancedTOTPPage> {
  // Global formKey to control the form
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  // Controllers for all the text fields
  TextEditingController _secretController = TextEditingController();
  TextEditingController _accountNameController = TextEditingController();
  TextEditingController _issuerController = TextEditingController();
  TextEditingController _digitsController = TextEditingController();
  TextEditingController _periodController = TextEditingController();
  TextEditingController _algorithmController = TextEditingController();

  // [_card] A fake card that displays info based on TOTP characteristics
  FakeTwoTPCard _card;

  void addItem() {
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    // Validate the form
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
      if (totpBloc.state is ChangedTOTPState
          && !(totpBloc.state as ChangedTOTPState).items.contains(item)) {
        totpBloc.add(AddItemEvent(item));
        Navigator.pushNamedAndRemoveUntil(
            context, "/", (r) => false);
        // TOAST Already Exists
      } else {
        // TODO: Toast Already Exists
      }
    }
  }

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
    // Set defaults if not filled
    var accountName =
        _validateString(_accountNameController.text) ?? "Account Name";
    var issuer = _validateString(_issuerController.text);
    var digits = _validateInt(_digitsController.text) ?? 6;
    var period = _validateInt(_periodController.text) ?? 30;
    var algorithm = _validateString(_algorithmController.text) ?? "SHA1";

    // Update the card
    setState(() {
      _card = FakeTwoTPCard(
        digits: digits,
        period: period,
        algorithm: algorithm,
        accountName: accountName,
        issuer: issuer,
      );
    });
    return _card;
  }

  @override
  void initState() {
    super.initState();
    _generateCard();
  }

  @override
  void dispose() {
    super.dispose();
    _secretController.dispose();
    _accountNameController.dispose();
    _issuerController.dispose();
    _digitsController.dispose();
    _periodController.dispose();
    _algorithmController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar = _appBar();
    var topPadding = MediaQuery.of(context).padding.top
        + appBar.preferredSize.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: ScrollConfiguration(
        behavior: NoOverScrollBehavior(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, topPadding, 24, 0),
            children: <Widget>[
              _card ?? FakeTwoTPCard(),
              SizedBox(height: 16),
              _addItemButton(),
              SizedBox(height: 16),
              _textFields()
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor
          .withOpacity(0.8),
      title: Text("Manual Input", style: TextStyles.appBarTitle),
      leading: Padding(
        padding: EdgeInsets.only(left: 14),
        child: IconButton(
          icon: Icon(LineIcons.angle_left_solid),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _addItemButton() {
    return CustomRaisedButton(
      color: Palette.primary,
      textColor: Colors.white,
      child: Text("Add Item",  style: TextStyles.buttonText),
      onTap: addItem,
    );
  }

  // All those form text-fields
  Widget _textFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
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
          labelText: "Digits (default: 6)",
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
          labelText: "Period (default: 30)",
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
          labelText: "Algorithm (default: SHA1)",
          onChanged: (_) {
            _generateCard();
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }
}

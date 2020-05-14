import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';

class AddItemsOptionPage extends StatefulWidget {
  @override
  _AddItemsOptionPageState createState() => _AddItemsOptionPageState();
}

class _AddItemsOptionPageState extends State<AddItemsOptionPage> {
  String _cameraPermissionsError = "";

  void onScanQRClick(context) async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (status.isGranted)
        Navigator.pushNamed(context, '/add/qr');
      else if (status.isPermanentlyDenied)
        setState(() {
          _cameraPermissionsError =
              "Please allow access to camera in your phone settings";
        });
      else if (status.isDenied)
        setState(() {
          _cameraPermissionsError =
              "Please allow access to the camera to scan QR codes";
        });
    }
    if (status.isGranted) {
      Navigator.pushNamed(context, '/add/qr');
    }
  }

  void onInputManualClick(context) {
    Navigator.pushNamed(context, '/add/advanced');
  }

  @override
  Widget build(BuildContext context) {
    var darkMode = Theme.of(context).brightness == Brightness.dark;
    var buttonTextColor = (darkMode) ? Colors.black : Colors.white;
    var buttonColor = (darkMode) ? Colors.white : Colors.black;

    var qrSVGPath = (Platform.isIOS)
        ? "assets/graphics/qr-ios.svg"
        : "assets/graphics/qr-android.svg";

    final Widget logoSVG = SvgPicture.asset(
      qrSVGPath,
      color: (darkMode) ? Colors.white : Colors.black,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
        Theme
            .of(context)
            .scaffoldBackgroundColor
            .withOpacity(0.8),
        centerTitle: true,
        title: Text("Add Code", style: TextStyles.appBarTitle),
        leading: Padding(
          padding: EdgeInsets.only(left: 14),
          child: IconButton(
            icon: Icon(LineIcons.angle_left_solid),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(
                  height: 240,
                  child: logoSVG,
                ),
                SizedBox(height: 32),
                RaisedButton(
                  elevation: 0,
                  highlightElevation: 0,
                  highlightColor:
                  (darkMode) ? Colors.grey[300] : Colors.grey[700],
                  onPressed: () {
                    onScanQRClick(context);
                  },
                  color: buttonColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(LineIcons.qrcode_solid, color: buttonTextColor),
                      SizedBox(width: 8),
                      Text("Scan QR",
                          style: TextStyles.buttonText
                              .copyWith(color: buttonTextColor)),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                (_cameraPermissionsError.isNotEmpty)
                    ? Center(
                    child: Text(
                      _cameraPermissionsError,
                      style: TextStyles.buttonText
                          .copyWith(color: Palette.medRed),
                      textAlign: TextAlign.center,
                    ))
                    : Container(),
                SizedBox(height: 12),
                OutlineButton(
                  onPressed: () {
                    onInputManualClick(context);
                  },
                  borderSide: BorderSide(
                    color: buttonColor,
                    width: 4,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  highlightedBorderColor: Colors.grey,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(LineIcons.pencil_alt_solid, color: buttonColor),
                      SizedBox(width: 8),
                      Text("Input manually",
                          style: TextStyles.buttonText
                              .copyWith(color: buttonColor)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

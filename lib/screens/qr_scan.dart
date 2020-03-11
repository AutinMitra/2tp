import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/components/toast.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
import 'package:twotp/theme/values.dart';
import 'package:twotp/totp/totp.dart';

class QRScanPage extends StatefulWidget {
  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  GlobalKey qrKey = GlobalKey();
  QRViewController _controller;
  String _lastQrScan = "";

  @override
  void initState() {
    super.initState();
    _controller?.resumeCamera();
  }

  @override
  void deactivate() {
    super.deactivate();
    _controller?.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: (Theme.of(context).brightness == Brightness.dark)
          ? Brightness.light
          : Brightness.dark,
    ));
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
              flex: 2,
              child: Stack(
                children: <Widget>[
                  QRView(
                    key: qrKey,
                    onQRViewCreated: (controller) {
                      _onQRViewCreated(context, controller);
                    },
                    overlay: QrScannerOverlayShape(
                        borderRadius: 10,
                        borderColor: Palette.accent,
                        borderWidth: 16.0,
                        overlayColor: Color(0x9A000000)),
                  ),
                  _QRBottomBar()
                ],
              )),
        ],
      ),
    );
  }

  void _onQRViewCreated(BuildContext context, QRViewController controller) {
    this._controller = controller;
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    controller.scannedDataStream.listen((data) {
      setState(() {
        TOTPItem item;
        try {
          item = TOTPItem.parseURI(data);
          if (!totpBloc.items.contains(item) && data != _lastQrScan) {
            controller.pauseCamera();
            totpBloc.add(AddItemEvent(item));
            // TODO: Add notif/indicator of success
            showToastWidget(ToastMessage(message: "Added!"),
              position: ToastPosition.bottom,
              duration: Values.toastDuration
            );
            Navigator.pop(context);
            Navigator.pushNamed(context, "/");
          } else {
            showToastWidget(
              ToastMessage(message: "Already Exists!", error: true),
              duration: Values.toastDuration
            );
          }
        } on FormatException catch (e) {
          // TODO: Add modal/notification of incorrect qr
        }
      });
      _lastQrScan = data;
    });
  }
}

class _QRBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: RaisedButton(
                      color: Palette.darkRed,
                      textColor: Colors.white,
                      child: Text("Cancel", style: TextStyles.buttonText),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: RaisedButton(
                      color: Colors.white,
                      textColor: Colors.black,
                      child:
                          Text("Input Manually", style: TextStyles.buttonText),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/add/advanced');
                      }),
                ),
              ],
            ),
          )),
    );
  }
}
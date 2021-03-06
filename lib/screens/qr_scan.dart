import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:twotp/blocs/totp/totp_bloc.dart';
import 'package:twotp/blocs/totp/totp_event.dart';
import 'package:twotp/blocs/totp/totp_state.dart';
import 'package:twotp/components/buttons.dart';
import 'package:twotp/theme/palette.dart';
import 'package:twotp/theme/text_styles.dart';
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

  /// Process QR data on arrival.
  /// [context] is the widget BuildContext
  /// [controller] is the QRViewController for the QRView
  void _onQRViewCreated(BuildContext context, QRViewController controller) {
    this._controller = controller;
    // ignore: close_sinks
    final TOTPBloc totpBloc = BlocProvider.of<TOTPBloc>(context);

    controller.scannedDataStream.listen((data) {
      setState(() {
        TOTPItem item;
        try {
          // Try Parsing the item
          item = TOTPItem.parseURI(data);

          // There is already data in the state, and the scan is not a duplicate
          if (totpBloc.state is ChangedTOTPState
              && !(totpBloc.state as ChangedTOTPState).items.contains(item)
              && data != _lastQrScan) {
            controller.pauseCamera();
            totpBloc.add(AddItemEvent(item));
            // TODO: Add notif/indicator of success
            Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
                context, "/", (r) => false);
          } else {
            // TODO: toast: already Exists
          }
        } on FormatException catch (e) {
          // TODO: Add modal/notification of incorrect QR
        }
      });
      _lastQrScan = data;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                _bottomBar()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
          child: CustomRaisedButton(
            color: Palette.darkRed,
            textColor: Colors.white,
            child: Text("Cancel",  style: TextStyles.buttonText),
            onTap: () { Navigator.pop(context); },
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricUtils {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate({reason: ""}) async {
    bool successfullyAuthenticated = false;
    try {
      successfullyAuthenticated = await _auth.authenticateWithBiometrics(
        localizedReason: reason,
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }
    return successfullyAuthenticated;
  }
}

import 'dart:math';
import 'dart:typed_data';

import "package:crypto/crypto.dart" show Hmac, sha1, sha256, sha512;
import "package:base32/base32.dart" show base32;

/// Generates TOTP codes
/// References
/// * https://www.youtube.com/watch?v=VOYxF12K1vE
/// * https://github.com/YC/another_authenticator/blob/master/lib/totp/totp_algorithm.dart
/// * https://github.com/YC/another_authenticator
class TOTP {
  static String generateOTP(String secret, int time,
      {int digits = 6, int period = 30, String algorithm = "SHA1"}) {
    // Get the total time since epoch, and then calculate the amount of steps
    var stepsSinceEpoch = time ~/ period;

    // Convert the steps to a byte list for use with HMAC
    var bytes = new Uint64List.fromList([stepsSinceEpoch])
        .buffer
        .asUint8List()
        .reversed
        .toList();
    var key = base32.decode(secret);

    // Choose the algorithm
    var hash = (algorithm == "SHA1")
        ? sha1
        : (algorithm == "SHA256") ? sha256 : sha512;
    // Get the HMAC
    var hmacSHA = Hmac(hash, key);
    var hmac = hmacSHA.convert(bytes).bytes;

    // The offset is the last byte
    int offset = hmac[hmac.length - 1] & 0xF;

    // Create the code the offsets
    final truncatedHash = ((hmac[offset] & 0x7F) << 24 |
        (hmac[offset + 1] & 0xFF) << 16 |
        (hmac[offset + 2] & 0xFF) << 8 |
        (hmac[offset + 3] & 0xFF));

    // Mod 10^6, convert to string and pad
    var stringCode = (truncatedHash % pow(10, digits)).toString();
    stringCode = stringCode.padLeft(digits, '0');
    return stringCode;
  }

  static String formatOTP(String code) {
    String formatted = code.substring(0, code.length ~/ 2) +
        " " +
        code.substring(code.length ~/ 2, code.length);
    return formatted;
  }
}

// A basic model of TOTP to be used with widgets
class TOTPItem {
  final String secret;
  final int digits;
  final int period;
  final String algorithm;
  final String accountName;
  final String issuer;

  TOTPItem(this.secret,
      {this.digits = 6,
      this.period = 30,
      this.algorithm = "SHA1",
      this.accountName = "",
      this.issuer = ""})
      : assert(digits == 6 || digits == 8),
        assert(period > 0),
        assert(algorithm == "SHA1" ||
            algorithm == "SHA256" ||
            algorithm == "SHA512");

//  TOTPItem.fromJSON(Map<String, dynamic> json)
//      : this.secret = json["secret"],
//        this.digits = json["digits"],
//        this.period = json["period"],
//        this.algorithm = json["algorithm"],
//        this.accountName = json["accountName"],
//        this.issuer = json["issuer"];

  String generateCode(int time, {pretty = false}) {
    String code = TOTP.generateOTP(secret, time,
        digits: this.digits, period: this.period, algorithm: this.algorithm);

    return (pretty) ? TOTP.formatOTP(code) : code;
  }

  static TOTPItem parseURI(String uri) {
    var parsed = Uri.parse(uri);
    if (parsed.authority != "totp" || parsed.scheme != "otpauth")
      throw new FormatException("Invalid otpauth url");
    if (parsed.pathSegments.length < 1)
      throw new FormatException("Must have at least one path segment");

    String secret = "";
    int digits = 6;
    int period = 30;
    String algorithm = "SHA1";
    String accountName = "";
    String issuer = "";

    // The first path of the OTP contains issuer and account name separated by :
    var splitFirstPath = parsed.pathSegments[0].split(":");
    accountName = splitFirstPath[0];

    Map<String, dynamic> queryParameters = parsed.queryParameters;
    // Make sure that the secret exists (fundamental to algorithm)
    if (queryParameters.containsKey("secret"))
      secret = queryParameters["secret"];
    else
      throw new FormatException("Query does not contain secret");

    // Check for optional parameters
    if (queryParameters.containsKey("issuer"))
      issuer = queryParameters["issuer"];
    if (queryParameters.containsKey("digits"))
      digits = int.parse(queryParameters["digits"]);
    if (queryParameters.containsKey("period"))
      period = int.parse(queryParameters["period"]);
    if (queryParameters.containsKey("algorithm"))
      algorithm = queryParameters["algorithm"].toUpperCase();
    try {
      return new TOTPItem(secret,
          digits: digits,
          period: period,
          algorithm: algorithm,
          accountName: accountName,
          issuer: issuer);
    } catch (error) {
      throw new FormatException("Invalid parameters");
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TOTPItem &&
          runtimeType == other.runtimeType &&
          secret == other.secret &&
          digits == other.digits &&
          period == other.period &&
          algorithm == other.algorithm &&
          accountName == other.accountName &&
          issuer == other.issuer;

  @override
  int get hashCode =>
      secret.hashCode ^
      digits.hashCode ^
      period.hashCode ^
      algorithm.hashCode ^
      accountName.hashCode ^
      issuer.hashCode;
}

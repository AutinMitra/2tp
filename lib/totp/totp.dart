import 'dart:math';
import 'dart:typed_data';

import "package:base32/base32.dart" show base32;
import "package:crypto/crypto.dart" show Hmac, sha1, sha256, sha512;
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:twotp/theme/card_colors.dart';

/// Generates TOTP codes
/// References
/// * https://www.youtube.com/watch?v=VOYxF12K1vE
/// * https://github.com/YC/another_authenticator/blob/master/lib/totp/totp_algorithm.dart
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
class TOTPItem extends Equatable {
  /// [secret] is a base32 encoded key, should be kept secret
  final String secret;

  /// [id] and ID describing the key
  final String id;

  /// [digits] the number of digits
  final int digits;

  /// [period] is the number of seconds each code is valid
  final int period;

  /// [algorithm] SHA1, SHA256, or SHA512
  final String algorithm;

  /// [accountName] the user of the code
  final String accountName;

  /// [issuer] the provider of the code
  final String issuer;

  /// [colorConfig] is the color configuration for the card
  final CardColorConfig colorConfig;

  TOTPItem._internal(this.secret, this.id,
      {this.digits = 6,
      this.period = 30,
      this.algorithm = "SHA1",
      this.accountName = "",
      this.issuer = "",
      this.colorConfig})
      : assert(digits == 6 || digits == 8),
        assert(period > 0),
        assert(algorithm == "SHA1" ||
            algorithm == "SHA256" ||
            algorithm == "SHA512");

  factory TOTPItem(secret, id,
    {digits = 6,
    period = 30,
    algorithm = "SHA1",
    accountName = "",
    issuer = "",
    colorConfig
  }) {
    colorConfig = colorConfig ?? CardColors.defaultConfig;
    if(CardColors.colors.containsKey(issuer?.toLowerCase()))
      colorConfig = CardColors.colors[issuer?.toLowerCase()];
    return TOTPItem._internal(secret, id,
      digits: digits,
      period: period,
      algorithm: algorithm,
      accountName: accountName,
      issuer: issuer,
      colorConfig: colorConfig
    );
  }

  // Generates a code, with the option of being formatted
  String generateCode(int time, {pretty = false}) {
    String code = TOTP.generateOTP(secret, time,
        digits: this.digits, period: this.period, algorithm: this.algorithm);

    return (pretty) ? TOTP.formatOTP(code) : code;
  }

  /// Parses the otpauth URI
  /// References
  /// * https://github.com/YC/another_authenticator/blob/master/lib/totp/totp_item.dart
  /// * https://github.com/google/google-authenticator/wiki/Key-Uri-Format
  static TOTPItem parseURI(String uri) {
    var parsed = Uri.parse(uri);
    if (parsed.authority != "totp" || parsed.scheme != "otpauth")
      throw new FormatException("Invalid otpauth url");
    if (parsed.pathSegments.length < 1)
      throw new FormatException("Must have at least one path segment");

    // Default values
    String secret = "";
    int digits = 6;
    int period = 30;
    String algorithm = "SHA1";
    String accountName = "";
    String issuer = "";

    // Label may contain a color to separate information
    var splitFirstPath = parsed.pathSegments[0].split(":");
    if (splitFirstPath.length > 1)
      accountName = splitFirstPath[1];
    else
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

    var colorConfig = CardColors.defaultConfig;
    if(CardColors.colors.containsKey(issuer?.toLowerCase()))
      colorConfig = CardColors.colors[issuer?.toLowerCase()];

    // Validate, otherwise throw error
    try {
      return new TOTPItem(secret, Uuid().v4(),
        digits: digits,
        period: period,
        algorithm: algorithm,
        accountName: accountName,
        issuer: issuer,
        colorConfig: colorConfig,
      );
    } catch (error) {
      throw new FormatException("Invalid parameters");
    }
  }

  // Just a validator for a TOTPItem
  static bool isValid(TOTPItem item) {
    try {
      assert(item.digits == 6 || item.digits == 8);
      assert(item.algorithm == 'SHA1' || item.algorithm == 'SHA256' ||
          item.algorithm == 'SHA512');
      assert(item.period > 0);
      assert(item.id != "" || item.id != null);
      assert(item.accountName != null);
      base32.decode(item.secret);
    } catch (e) {
      return false;
    }
    // Yay! Everything passed
    return true;
  }

  // Parses JSON alongside with additional key
  factory TOTPItem.fromJSON(Map<String, dynamic> json, String secretKey) {
    var digits = json["digits"];
    var period = json["period"];
    var algorithm = json["algorithm"];
    var accountName = json["accountName"];
    var issuer = json["issuer"];
    var id = json["id"];
    var secret = secretKey;
    var colorConfig = CardColorConfig.fromJSON(json);

    return TOTPItem(
      secret, id,
      digits: digits,
      period: period,
      algorithm: algorithm,
      accountName: accountName,
      issuer: issuer,
      colorConfig: colorConfig
    );
  }

  // Makes everything in JSON format except secret
  Map<String, dynamic> toJSON() {
    return {
      "digits": digits,
      "period": period,
      "algorithm": algorithm,
      "accountName": accountName,
      "issuer": issuer,
      "id": id,
      ...colorConfig.toJson(),
    };
  }

  @override
  String toString() {
    return 'TOTPItem{id: $id, digits: $digits, period: $period, algorithm: $algorithm, accountName: $accountName, issuer: $issuer, colorConfg: $colorConfig}';
  }

  @override
  List<Object> get props => [digits, period, algorithm, accountName, issuer];
}

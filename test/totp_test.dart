import 'package:flutter_test/flutter_test.dart';
import 'package:twotp/totp/totp.dart';

void main() {
  // TOTP algorithm test cases
  // TODO: Add test cases for SHA256 and SHA512
  // TODO: Add more OTP combinations
  test('Generate OTP key - FJWBASJDHEKDFKSA', () {
    expect(TOTP.generateOTP("FJWBASJDHEKDFKSA", 1580234437), "269029");
  });
  test('Generate OTP key - FJWBASJDHEKDFKSA 60 seconds', () {
    expect(
        TOTP.generateOTP("FJWBASJDHEKDFKSA", 1580234769, period: 60), "997960");
  });
  test('Generate OTP key - FJWBASJDHEKDFKSA 8 digits', () {
    expect(TOTP.generateOTP("FJWBASJDHEKDFKSA", 1580234826, digits: 8),
        "68061882");
  });
  test('Generate OTP key - Incorrect amount of digits', () {
    try {
      TOTP.generateOTP("FJWBASJDHEKDFKSA", 1580234826, digits: 9);
    } catch (error) {
      expect(error.message, 'Invalid parameters');
    }
  });
  test('Generate OTP key - Invalid algorithm', () {
    try {
      TOTP.generateOTP("FJWBASJDHEKDFKSA", 1580234826, algorithm: "MD5");
    } catch (error) {
      expect(error.message, 'Invalid parameters');
    }
  });

  // Test cases for URI parsing
  test('Parse TOTP URI - 1', () {
    String uri =
        "otpauth://totp/Alice?secret=OADV5KKZ2UUWJT5J&issuer=BigCompany&algorithm=SHA256&digits=6&period=30";
    TOTPItem fromURI = TOTPItem.parseURI(uri);
    TOTPItem expected = new TOTPItem("OADV5KKZ2UUWJT5J",
        digits: 6,
        period: 30,
        algorithm: "SHA256",
        accountName: "Alice",
        issuer: "BigCompany");
    expect(fromURI, expected);
  });
  test('Parse TOTP URI - Invalid scheme', () {
    String uri =
        "wrongscheme://totp/Alice?secret=OADV5KKZ2UUWJT5J&issuer=BigCompany&algorithm=SHA256&digits=6&period=30";
    try {
      TOTPItem.parseURI(uri);
    } catch (error) {
      expect(error.message, "Invalid otpauth url");
    }
  });
  test('Parse TOTP URI - Invalid authority', () {
    String uri =
        "otpauth://totp/Alice?secret=OADV5KKZ2UUWJT5J&issuer=BigCompany&algorithm=SHA256&digits=6&period=30";
    try {
      TOTPItem.parseURI(uri);
    } catch (error) {
      expect(error.message, "Invalid otpauth url");
    }
  });
}

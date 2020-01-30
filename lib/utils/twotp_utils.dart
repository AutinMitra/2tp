import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/file_utils.dart';

class TwoTPUtils {
  // SharedPreferences store configs, secureStorage stores secrets

  static String darkModePrefs = "darkModeOn";
  static SharedPreferences prefs;
  static FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  // Loads all the TOTPitems from a JSON
  static Future<List<TOTPItem>> loadItemsFromFile(String filename) async {
    // If there is no file, there is no items
    if (!await FileUtils.fileExists(filename)) return [];

    // Read the file
    var data = await FileUtils.readFile(filename);
    List decoded = json.decode(data);
    List res = [];
    for (Map<String, dynamic> item in decoded) {
      // Get the secret from secured storage
      String secret = await _secureStorage.read(key: "${item["id"]}");
      res.add(TOTPItem.fromJSON(item, secret));
    }
    return res;
  }

  // Converts files to JSON while encrypting secret keys and saving
  static Future saveItemsToFile(List<TOTPItem> items, String filename) {
    List jsonList = [];
    for (TOTPItem item in items) {
      // Save the secret in a secured storage
      _secureStorage.write(key: "${item.id}", value: "${item.secret}");
      jsonList.add(item.toJSON());
    }
    // Turn JSON list to string
    var data = json.encode(jsonList);
    return FileUtils.writeFile(filename, data).then((file) => {});
  }
}

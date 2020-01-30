import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twotp/totp/totp.dart';
import 'package:twotp/utils/file_utils.dart';

class TwoTPUtils {
  static SharedPreferences prefs;
  static FlutterSecureStorage _secureStorage = new FlutterSecureStorage();

  static Future<List<TOTPItem>> loadItemsFromFile(String filename) async {
    if(!await FileUtils.fileExists(filename))
      return [];

    var data = await FileUtils.readFile(filename);
    List decoded = json.decode(data);
    List res = [];
    for(Map<String, dynamic> item in decoded) {
      String secret = await _secureStorage.read(key: "${item["id"]}");
      res.add(TOTPItem.fromJSON(item, secret));
    }
    return res;
  }

  static Future saveItemsToFile(List<TOTPItem> items, String filename) {
    List jsonList = [];
    for(TOTPItem item in items) {
      _secureStorage.write(key: "${item.id}", value: "${item.secret}");
      jsonList.add(item.toJSON());
    }
    var data = json.encode(jsonList);
    return FileUtils.writeFile(filename, data).then((file) => {});
  }
}
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> get _path async =>
      (await getApplicationDocumentsDirectory()).path;

  static Future<File> getFile(String file) async {
    var path = await _path;
    return File('$path/$file');
  }

  static Future<bool> fileExists(String file) async {
    return (await getFile(file)).exists();
  }

  static Future<String> readFile(String file) async {
    return (await getFile(file)).readAsString();
  }

  static Future<File> writeFile(String file, String content) async {
    return (await getFile(content)).writeAsString(content);
  }
}

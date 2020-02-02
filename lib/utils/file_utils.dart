import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  // Gives the path of the app document dir, for internal use only
  static Future<String> get _path async =>
      (await getApplicationDocumentsDirectory()).path;

  // Get's files from application doc dir
  static Future<File> getFile(String file) async {
    var path = await _path;
    return File('$path/$file');
  }

  // Checks if a given file exists
  static Future<bool> fileExists(String file) async {
    return (await getFile(file)).exists();
  }

  // Reads a file into a string
  static Future<String> readFile(String file) async {
    return (await getFile(file)).readAsString();
  }

  // Write a string to a file
  static Future<File> writeFile(String file, String content) async {
    return (await getFile(file)).writeAsString(content);
  }
}

import 'package:flutter/material.dart';


class CardColors {
  static const CardColorConfig defaultConfig = CardColorConfig(
    color: const Color(0xFFFFFFFF),
    dark: false
  );
  static const CardColorConfig githubConfig = CardColorConfig(
    color: const Color(0xFF6e5494),
    dark: true,
  );
  static const CardColorConfig facebookConfig = CardColorConfig(
    color: const Color(0xFF4267B2),
    dark: true
  );
  static const CardColorConfig amazonConfig = CardColorConfig(
    color: const Color(0xFFE7A688),
    dark: false
  );
  static const CardColorConfig appleConfig = CardColorConfig(
    color: const Color(0xFFF96F6F),
    dark: false
  );
  static const CardColorConfig googleConfig =  CardColorConfig(
    color: const Color(0xFF3ddc84),
    dark: false
  );
  static const CardColorConfig twitterConfig = CardColorConfig(
    color: const Color(0xFF1DA1F2),
    dark: false
  );
  static const CardColorConfig dropboxConfig = CardColorConfig(
    color: const Color(0xFF0060FF),
    dark: true
  );
  static const CardColorConfig krakenConfig = CardColorConfig(
    color: const Color(0xFF5741D9),
    dark: true
  );

  static Map<String, CardColorConfig> colors = {
    "github": githubConfig,
    "facebook": facebookConfig,
    "amazon": amazonConfig,
    "apple": appleConfig,
    "google": googleConfig,
    "twitter": twitterConfig,
    "dropbox": dropboxConfig,
    "kraken": krakenConfig,
  };
}

@immutable
class CardColorConfig {
  final Color color;
  final bool dark;

  const CardColorConfig({@required this.color, @required this.dark})
  : assert(color != null);

  factory CardColorConfig.fromJSON(Map<String, dynamic> json) {
   if(!json.containsKey("cardColor") || !json.containsKey("textColor") || !json.containsKey("cardDark"))
     return CardColors.defaultConfig;

    var color = Color(json["cardColor"]);
    var dark = json["cardDark"];

    return CardColorConfig(
      color: color,
      dark: dark,
    );
  }
}
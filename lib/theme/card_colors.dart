import 'package:flutter/material.dart';


class CardColors {
  static final CardColorConfig defaultConfig = CardColorConfig(
    color: const Color(0xFFFFFFFF),
    dark: false,
    numberBgColor: Color(0x10000000)
  );
  static final CardColorConfig githubConfig = CardColorConfig(
    color: const Color(0xFF6e5494),
    dark: true,
  );
  static final CardColorConfig facebookConfig = CardColorConfig(
    color: const Color(0xFF4267B2),
    dark: true
  );
  static final CardColorConfig amazonConfig = CardColorConfig(
    color: const Color(0xFFE7A688),
    dark: false
  );
  static final CardColorConfig appleConfig = CardColorConfig(
    color: const Color(0xFFF96F6F),
    dark: false,
    numberBgColor: Color(0x40ffffff)
  );
  static final CardColorConfig googleConfig =  CardColorConfig(
    color: const Color(0xFF3ddc84),
    dark: false
  );
  static final CardColorConfig twitterConfig = CardColorConfig(
    color: const Color(0xFF1DA1F2),
    dark: false,
    numberBgColor: Color(0x40ffffff)
  );
  static final CardColorConfig dropboxConfig = CardColorConfig(
    color: const Color(0xFF0060FF),
    dark: true
  );
  static final CardColorConfig krakenConfig = CardColorConfig(
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
  final Color numberBgColor;
  final bool dark;

  const CardColorConfig._internal({
    @required this.color,
    @required this.dark,
    @required this.numberBgColor,
  })
  : assert(color != null),
    assert(dark != null),
    assert(numberBgColor != null);

  factory CardColorConfig({
    @required color,
    @required dark,
    numberBgColor,
  }) {
    if(numberBgColor == null)
      numberBgColor = dark ? Color(0x40000000) : Color(0x40ffffff);

    return CardColorConfig._internal(
      color: color,
      dark: dark,
      numberBgColor: numberBgColor
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      "cardColor": color.value,
      "cardNumberBgColor": numberBgColor.value,
      "cardDark": dark,
    };
  }
}
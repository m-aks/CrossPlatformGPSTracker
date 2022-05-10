import 'package:flutter/material.dart';

class CustomColors {
  static Color primaryColor = getColorFromHex('#DD90F1');
  static Color secondaryColor = getColorFromHex('#33FFF3');
  static Color colorHighlight = getColorFromHex('#212E3E');
  static Color polyline = Colors.blue;
  static Color icon = Colors.black;

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      var color = Color(int.parse("0x$hexColor"));
      return color;
    }
    return Colors.black54;
  }
}

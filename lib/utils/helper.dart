import 'dart:core';
import 'dart:math';

import 'package:intl/intl.dart';

class Helper {
  static fullDateToString(int milliseconds) {
    return DateFormat("dd.MM.yyyy HH:mm")
        .format(DateTime.fromMillisecondsSinceEpoch(milliseconds));
  }

  static getTimeFromInt(int seconds) {
    int min = (seconds / 60).floor();
    int sec = (seconds - min * 60);
    StringBuffer res = StringBuffer();
    if (min ~/ 10 == 0) {
      res.write('0');
      res.write(min);
    } else {
      res.write(min);
    }
    res.write(":");
    if (sec ~/ 10 == 0) {
      res.write('0');
      res.write(sec);
    } else {
      res.write(sec);
    }
    return res.toString();
  }

  static String distanceUnits(int distance) {
    if (distance >= 1000) {
      var result = (distance / 1000).toString();
      return result.substring(0, result.indexOf('.') + 3) + "km";
    } else {
      return distance.toString() + "m";
    }
  }

  static double toFixed(double speed, [int digits = 2]) {
    int result = (speed * pow(10, digits)).toInt();
    return result / pow(10, digits);
  }
}

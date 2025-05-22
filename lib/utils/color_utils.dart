import 'package:flutter/material.dart';

Color getColorFromString(String colorString) {
  switch (colorString.toLowerCase()) {
    case 'red':
      return Colors.red;
    case 'pink':
      return Colors.pink;
    case 'purple':
      return Colors.purple;
    case 'deeppurple':
      return Colors.deepPurple;
    case 'indigo':
      return Colors.indigo;
    case 'blue':
      return Colors.blue;
    case 'lightblue':
      return Colors.lightBlue;
    case 'cyan':
      return Colors.cyan;
    case 'teal':
      return Colors.teal;
    case 'green':
      return Colors.green;
    case 'lightgreen':
      return Colors.lightGreen;
    case 'lime':
      return Colors.lime;
    case 'yellow':
      return Colors.yellow;
    case 'amber':
      return Colors.amber;
    case 'orange':
      return Colors.orange;
    case 'deeporange':
      return Colors.deepOrange;
    case 'brown':
      return Colors.brown;
    case 'grey':
      return Colors.grey;
    default:
      break;
  }

  try {
    if (colorString.contains('MaterialColor')) {
      final valueString = RegExp(r'value: (\d+)')
          .firstMatch(colorString)
          ?.group(1);
      if (valueString != null) {
        return Color(int.parse(valueString));
      }
    }

    if (colorString.contains('Color(')) {
      final valueString = RegExp(r'Color\((\d+)\)')
          .firstMatch(colorString)
          ?.group(1);
      if (valueString != null) {
        return Color(int.parse(valueString));
      }
    }

    return Colors.blue;
  } catch (_) {
    return Colors.blue;
  }
}

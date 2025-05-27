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
      final valueString = RegExp(
        r'value: (\d+)',
      ).firstMatch(colorString)?.group(1);
      if (valueString != null) {
        return Color(int.parse(valueString));
      }
    }

    if (colorString.contains('Color(')) {
      final valueString = RegExp(
        r'Color\((\d+)\)',
      ).firstMatch(colorString)?.group(1);
      if (valueString != null) {
        return Color(int.parse(valueString));
      }
    }

    return Colors.blue;
  } catch (_) {
    return Colors.blue;
  }
}

String getStringFromColor(Color color) {
  if (color == Colors.red) return 'red';
  if (color == Colors.pink) return 'pink';
  if (color == Colors.purple) return 'purple';
  if (color == Colors.deepPurple) return 'deepPurple';
  if (color == Colors.indigo) return 'indigo';
  if (color == Colors.blue) return 'blue';
  if (color == Colors.lightBlue) return 'lightBlue';
  if (color == Colors.cyan) return 'cyan';
  if (color == Colors.teal) return 'teal';
  if (color == Colors.green) return 'green';
  if (color == Colors.lightGreen) return 'lightGreen';
  if (color == Colors.lime) return 'lime';
  if (color == Colors.yellow) return 'yellow';
  if (color == Colors.amber) return 'amber';
  if (color == Colors.orange) return 'orange';
  if (color == Colors.deepOrange) return 'deepOrange';
  if (color == Colors.brown) return 'brown';
  if (color == Colors.grey) return 'grey';
  return 'blue'; // Default color
}

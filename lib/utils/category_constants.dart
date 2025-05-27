import 'package:flutter/material.dart';

/// A utility class for category-related constants.
class CategoryConstants {
  /// List of available colors for categories
  static final List<Color> availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  /// Map of category names to their icon file paths
  static final Map<String, String> availableIcons = {
    'Food': 'assets/icons/categories/food.png',
    'Transportation': 'assets/icons/categories/transportation.png',
    'Entertainment': 'assets/icons/categories/entertainment.png',
    'Shopping': 'assets/icons/categories/shopping-cart.png',
    'Bills': 'assets/icons/categories/bill.png',
    'Healthcare': 'assets/icons/categories/healthcare.png',
    'Education': 'assets/icons/categories/education.png',
    'Salary': 'assets/icons/categories/salary.png',
    'Business': 'assets/icons/categories/business.png',
    'Investment': 'assets/icons/categories/investment.png',
  };
}

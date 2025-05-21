import 'package:flutter/material.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key});

  // Reference to the current state for manipulation from outside
  static _CategoriesListState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CategoriesListState>();
  }

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  // Sample category data - replace with your actual data source
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Food', 'color': Colors.red, 'icon': 'assets/icons/categories/food.png', 'type': 'expense'},
    {'name': 'Transportation', 'color': Colors.blue, 'icon': 'assets/icons/categories/transportation.png', 'type': 'expense'},
    {'name': 'Entertainment', 'color': Colors.green, 'icon': 'assets/icons/categories/entertainment.png', 'type': 'expense'},
    {'name': 'Shopping', 'color': Colors.orange, 'icon': 'assets/icons/categories/shopping-cart.png', 'type': 'expense'},
    {'name': 'Bills', 'color': Colors.purple, 'icon': 'assets/icons/categories/bill.png', 'type': 'expense'},
    {'name': 'Health', 'color': Colors.teal, 'icon': 'assets/icons/categories/healthcare.png', 'type': 'expense'},
    {'name': 'Education', 'color': Colors.amber, 'icon': 'assets/icons/categories/education.png', 'type': 'expense'},
    {'name': 'Salary', 'color': Colors.green, 'icon': 'assets/icons/categories/salary.png', 'type': 'income'},
    {'name': 'Business', 'color': Colors.blue, 'icon': 'assets/icons/categories/business.png', 'type': 'income'},
    {'name': 'Investment', 'color': Colors.purple, 'icon': 'assets/icons/categories/investment.png', 'type': 'income'},
  ];

  // Selected type filter (null for all categories, 'income' or 'expense' for specific types)
  String? _selectedType;

  // Method to add a new category
  void addCategory(Map<String, dynamic> category) {
    setState(() {
      _categories.add(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: category['color'],
                    shape: BoxShape.circle,
                  ),
                ),
                if (category.containsKey('icon') && category['icon'] != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Image.asset(
                      category['icon'] as String,
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(width: 24, height: 24);
                      },
                    ),
                  ),
              ],
            ),
            title: Text(category['name']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit category functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Delete category functionality
                    setState(() {
                      _categories.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

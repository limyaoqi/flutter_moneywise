import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/nav/navigation.dart';
import 'package:moneywise/widget/category/category_item.dart';

class CategoriesList extends StatefulWidget {
  const CategoriesList({super.key});

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
  final CategoryRepoFirestore _categoryRepo = CategoryRepoFirestore();
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          SizedBox(
            width: 40,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              onPressed: () => _navigateToAdd(context),
              child: const Icon(Icons.add, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'all' ? null : value;
              });
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'all',
                    child: Text('All Categories'),
                  ),
                  const PopupMenuItem(
                    value: 'income',
                    child: Text('Income Categories'),
                  ),
                  const PopupMenuItem(
                    value: 'expense',
                    child: Text('Expense Categories'),
                  ),
                ],
            icon: const Icon(Icons.filter_list),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<Category>>(
        stream: _categoryRepo.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          List<Category> categories = snapshot.data ?? [];

          // Filter categories by type if a type filter is set
          if (_selectedType != null) {
            categories =
                categories.where((cat) => cat.type == _selectedType).toList();
          }

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedType == null
                        ? 'No categories found'
                        : 'No ${_selectedType} categories found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToAdd(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Category'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return CategoryItem(category: category);
            },
          );
        },
      ),
    );
  }

  void _navigateToAdd(BuildContext context) {
    context.pushNamed(Screens.manageCategory.name);
  }
}

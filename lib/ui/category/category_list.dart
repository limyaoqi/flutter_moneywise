import 'package:flutter/material.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/utils/color_utils.dart';

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
  final CategoryRepoFirestore _categoryRepo = CategoryRepoFirestore();
  // Selected type filter (null for all categories, 'income' or 'expense' for specific types)
  String? _selectedType;

  // Method to filter categories by type
  void setTypeFilter(String? type) {
    setState(() {
      _selectedType = type;
    });
  }

  // Method to add a new category
  Future<void> addCategory(Category category) async {
    await _categoryRepo.addCategory(category);
  }

  // Method to delete category
  Future<void> deleteCategory(String id) async {
    await _categoryRepo.deleteCategory(id);
  }

  // Handler for when edit button is pressed
  void _handleEditCategory(Category category) {
    // Edit category functionality
    // To be implemented
  }

  // Build the category icon
  Widget _buildCategoryIcon(Category category) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: getColorFromString(category.color),
        shape: BoxShape.circle,
      ),
      child:
          category.icon != null
              ? Center(
                child: Image.asset(
                  category.icon!,
                  width: 24,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(width: 24, height: 24);
                  },
                ),
              )
              : null,
    );
  }

  // Build the action buttons for each category
  Widget _buildCategoryActions(Category category) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _handleEditCategory(category),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => deleteCategory(category.id),
        ),
      ],
    );
  }

  // Build a category list item
  Widget _buildCategoryItem(Category category) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: _buildCategoryIcon(category),
        title: Text(category.name),
        trailing: _buildCategoryActions(category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: _categoryRepo.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories found'));
        }

        // Filter categories by type if a type filter is set
        List<Category> categories = snapshot.data!;
        if (_selectedType != null) {
          categories =
              categories.where((cat) => cat.type == _selectedType).toList();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryItem(categories[index]);
          },
        );
      },
    );
  }

  // Helper method to convert color string to Color object
}

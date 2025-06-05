import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/nav/navigation.dart';
import 'package:moneywise/utils/color_utils.dart';
import 'package:moneywise/widget/dialogs/confirm_delete_dialog.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: _buildCategoryIcon(category),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Type: ${category.type.toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            color: category.type == 'income' ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _navigateToEdit(context, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, category),
            ),
          ],
        ),
        onTap: () => _showCategoryDetails(context, category),
        onLongPress: () => _showCategoryOptions(context, category),
      ),
    );
  }

  Widget _buildCategoryIcon(Category category) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: getColorFromString(category.color),
      child:
          category.icon != null
              ? Image.asset(
                category.icon!,
                width: 24,
                height: 24,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.category, color: Colors.white);
                },
              )
              : const Icon(Icons.category, color: Colors.white),
    );
  }

  void _showCategoryDetails(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            expand: false,
            builder: (_, controller) {
              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildCategoryIcon(category),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDetailItem(
                      context,
                      'Type:',
                      category.type.toUpperCase(),
                    ),
                    _buildDetailItem(context, 'Color:', category.color),
                    if (category.id != null)
                      _buildDetailItem(context, 'ID:', category.id!),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToEdit(context, category);
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _confirmDelete(context, category);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showCategoryOptions(BuildContext context, Category category) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Category'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEdit(context, category);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Category'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, category);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToEdit(BuildContext context, Category category) {
    context.pushNamed(
      Screens.manageCategory.name,
      queryParameters: {'categoryId': category.id ?? ''},
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    ConfirmDeleteDialog.show(
      context: context,
      content: 'Are you sure you want to delete this category?',
      onConfirm: () => _deleteCategory(context, category),
      confirmColor: Colors.red,
    );
  }

  Future<void> _deleteCategory(BuildContext context, Category category) async {
    try {
      final categoryRepo = CategoryRepoFirestore();

      // Check if the category is used in any transactions
      final bool isInUse = await categoryRepo.isCategoryUsedInTransactions(
        category.id!,
      );

      if (isInUse) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Cannot delete category that is used in transactions',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Proceed with deletion if not in use
      await categoryRepo.deleteCategory(category.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete category: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

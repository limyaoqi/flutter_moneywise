import 'package:moneywise/data/model/category.dart';

abstract class CategoryRepo {
  Stream<List<Category>> getCategories();

  Future<Category?> getCategoryById(String id);

  Future<void> addCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}
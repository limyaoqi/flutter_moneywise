import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';

abstract class CategoryRepo {
  Stream<List<Category>> getCategories();

  Future<List<Category>> getCategoriesByType(TransactionType type);

  Future<Category?> getCategoryById(String id);

  Future<void> addCategory(Category category);

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String id);
}
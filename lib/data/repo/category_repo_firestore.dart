import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';

class CategoryRepoFirestore {
  static final CategoryRepoFirestore _instance =
      CategoryRepoFirestore._init();
  
  CategoryRepoFirestore._init();

  factory CategoryRepoFirestore() {
    return _instance;
  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get collection reference for current user's transactions
  CollectionReference<Map<String, dynamic>> get _categoryCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users/$userId/categories');
  }

  Stream<List<Category>> getCategories() {
    return _categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category.fromMap(data);
      }).toList();
    });
  }

  Future<List<Category>> getCategoriesByType(TransactionType type) async {
    final String typeString = type == TransactionType.income ? 'income' : 'expense';
    final snapshot = await _categoryCollection
        .where('type', isEqualTo: typeString)
        .get();
    return snapshot.docs.map((doc) {
      return Category.fromMap(doc.data());
    }).toList();
  }

 Future<Category?> getCategoryById(String id) async {
    final doc = await _categoryCollection.doc(id).get();
    if (doc.exists) {
      return Category.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> addCategory(Category category) async {
    await _categoryCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _categoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _categoryCollection.doc(id).delete();
  } 
}
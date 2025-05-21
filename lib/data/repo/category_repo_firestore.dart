import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneywise/data/model/category.dart';

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
  CollectionReference<Map<String, dynamic>> get _CategoryCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users/$userId/categories');
  }

  Stream<List<Category>> getCategories() {
    return _CategoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Category.fromMap(data);
      }).toList();
    });
  }

 Future<Category?> getCategoryById(String id) async {
    final doc = await _CategoryCollection.doc(id).get();
    if (doc.exists) {
      return Category.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> addCategory(Category category) async {
    await _CategoryCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) async {
    await _CategoryCollection.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _CategoryCollection.doc(id).delete();
  } 
}
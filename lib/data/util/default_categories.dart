import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:moneywise/data/model/category.dart';

class DefaultCategoriesUtil {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final uuid = Uuid();

  /// Check if the user already has categories
  static Future<bool> userHasCategories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return false;
    }

    final snapshot =
        await _firestore.collection('users/$userId/categories').limit(1).get();

    return snapshot.docs.isNotEmpty;
  }

  /// Initialize default categories for a new user
  static Future<void> initializeDefaultCategories() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (await userHasCategories()) {
      return;
    }

    final batch = _firestore.batch();
    final categoriesCollection = _firestore.collection(
      'users/$userId/categories',
    );

    final expenseCategories = [
      Category(
        id: uuid.v4(),
        name: 'Food',
        color: 'red',
        icon: 'assets/icons/categories/food.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Transportation',
        color: 'blue',
        icon: 'assets/icons/categories/transportation.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Entertainment',
        color: 'green',
        icon: 'assets/icons/categories/entertainment.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Shopping',
        color: 'orange',
        icon: 'assets/icons/categories/shopping-cart.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Bills',
        color: 'purple',
        icon: 'assets/icons/categories/bill.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Health',
        color: 'teal',
        icon: 'assets/icons/categories/healthcare.png',
        type: 'expense',
      ),
      Category(
        id: uuid.v4(),
        name: 'Education',
        color: 'amber',
        icon: 'assets/icons/categories/education.png',
        type: 'expense',
      ),
    ];

    final incomeCategories = [
      Category(
        id: uuid.v4(),
        name: 'Salary',
        color: 'green',
        icon: 'assets/icons/categories/salary.png',
        type: 'income',
      ),
      Category(
        id: uuid.v4(),
        name: 'Business',
        color: 'blue',
        icon: 'assets/icons/categories/business.png',
        type: 'income',
      ),
      Category(
        id: uuid.v4(),
        name: 'Investment',
        color: 'purple',
        icon: 'assets/icons/categories/investment.png',
        type: 'income',
      ),
    ];

    final allCategories = [...expenseCategories, ...incomeCategories];

    for (final category in allCategories) {
      final docRef = categoriesCollection.doc(category.id);
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }
}

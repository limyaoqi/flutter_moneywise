import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/model/transaction_filter.dart';
import 'package:moneywise/data/repo/transaction_repo.dart';

class TransactionRepoFirestore implements TransactionRepo {
  static final TransactionRepoFirestore _instance =
      TransactionRepoFirestore._init();

  TransactionRepoFirestore._init();

  factory TransactionRepoFirestore() {
    return _instance;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get collection reference for current user's transactions
  CollectionReference<Map<String, dynamic>> get _transactionsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users/$userId/transactions');
  }

  @override
  Stream<List<Transaction>> getTransactions({TransactionFilter? filter}) {
    Query<Map<String, dynamic>> query =
        _transactionsCollection; // Apply required filters for transactionType and paymentMethod
    if (filter != null) {
      // transactionType filter is required
      if (filter.transactionType != null) {
        query = query.where(
          'transactionType',
          isEqualTo: filter.transactionType?.name,
        );
      }

      // paymentMethod filter is required
      if (filter.paymentMethod != null &&
          filter.paymentMethod != TransactionFilterPaymentMethod.all) {
        switch (filter.paymentMethod) {
          case TransactionFilterPaymentMethod.tng:
            query = query.where('paymentMethod', isEqualTo: 'tng');
            break;
          case TransactionFilterPaymentMethod.bank:
            query = query.where('paymentMethod', isEqualTo: 'bank');
            break;
          case TransactionFilterPaymentMethod.cash:
            query = query.where('paymentMethod', isEqualTo: 'cash');
            break;
          default:
            break;
        }
      }

      // Handle date filtering based on dateMethod and dateRequired
      if (filter.dateMethod != null &&
          filter.dateMethod != TransactionFilterDateMethod.all &&
          filter.dateRequired != null) {
        switch (filter.dateMethod) {
          case TransactionFilterDateMethod.weekly:
            // Filter by year
            final year = filter.dateRequired ?? '';
            if (year.isNotEmpty) {
              final startOfYear = DateTime(int.parse(year));
              final endOfYear = DateTime(int.parse(year) + 1, 1, 1);

              query = query
                  .where(
                    'date',
                    isGreaterThanOrEqualTo: startOfYear.toIso8601String(),
                  )
                  .where('date', isLessThan: endOfYear.toIso8601String());
            }
            break;
          case TransactionFilterDateMethod.monthly:
            // Filter by month (format: "YYYY-MM")
            final dateRequired = filter.dateRequired ?? '';
            if (dateRequired.isNotEmpty) {
              final parts = dateRequired.split('-');
              if (parts.length == 2) {
                final year = int.parse(parts[0]);
                final month = int.parse(parts[1]);

                final startOfMonth = DateTime(year, month);
                final endOfMonth = DateTime(year, month + 1);

                query = query
                    .where(
                      'date',
                      isGreaterThanOrEqualTo: startOfMonth.toIso8601String(),
                    )
                    .where('date', isLessThan: endOfMonth.toIso8601String());
              }
            }
            break;
          case TransactionFilterDateMethod.daily:
            // Filter by specific date (format: "YYYY-MM-DD")
            final dateRequired = filter.dateRequired ?? '';
            if (dateRequired.isNotEmpty) {
              final date = DateTime.parse(dateRequired);
              final nextDay = date.add(const Duration(days: 1));

              query = query
                  .where('date', isGreaterThanOrEqualTo: date.toIso8601String())
                  .where('date', isLessThan: nextDay.toIso8601String());
            }
            break;
          default:
            // Do nothing if null or not matched
            break;
        }
      }

      // Category filter - commented out for now as per request
      /*
      if (filter.categoryId != null) {
        query = query.where('categoryId', isEqualTo: filter.categoryId);
      }
      */
    }

    // Order by date (newest first)
    query = query.orderBy(
      'date',
      descending: true,
    ); // Return as stream with error handling
    try {
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          try {
            final data = doc.data();
            return Transaction.fromMap(data).copy(id: doc.id);
          } catch (e) {
            print('Error parsing transaction document ${doc.id}: $e');
            rethrow;
          }
        }).toList();
      });
    } catch (e) {
      print('Error in getTransactions: $e');
      rethrow;
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    if (id.isEmpty) {
      return null;
    }

    final docSnapshot = await _transactionsCollection.doc(id).get();
    if (!docSnapshot.exists) {
      return null;
    }

    final data = docSnapshot.data()!;
    return Transaction.fromMap(data).copy(id: docSnapshot.id);
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      // No ID provided, let Firestore generate one
      await _transactionsCollection.add(transaction.toMap());
    } else {
      // ID provided, use it
      await _transactionsCollection
          .doc(transaction.id)
          .set(transaction.toMap());
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    if (transaction.id == null || transaction.id!.isEmpty) {
      throw Exception('Cannot update transaction without an ID');
    }
    await _transactionsCollection
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _transactionsCollection.doc(id).delete();
  }

  @override
  Future<double> getTotalAmount({
    required TransactionType transactionType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Query<Map<String, dynamic>> query = _transactionsCollection.where(
      'transactionType',
      isEqualTo: transactionType,
    );

    // Apply date filters if provided
    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: startDate.toIso8601String(),
      );
    }

    if (endDate != null) {
      final endDatePlusOne = endDate.add(const Duration(days: 1));
      query = query.where('date', isLessThan: endDatePlusOne.toIso8601String());
    }

    final snapshot = await query.get();

    // Calculate the total amount
    double total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      total += (data['amount'] as num).toDouble();
    }

    return total;
  }
}

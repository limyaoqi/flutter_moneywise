import 'package:moneywise/data/model/transaction.dart';

class TransactionFilter {
  final String? dateMethod;
  final String? dateRequired;
  final String? categoryId;
  final TransactionType? transactionType;
  final TransactionFilterPaymentMethod? paymentMethod;

  TransactionFilter({
    this.dateMethod,
    this.dateRequired,
    this.categoryId,
    required this.transactionType,
    required this.paymentMethod,
  });
}

abstract class TransactionRepo {
  Stream<List<Transaction>> getTransactions({TransactionFilter? filter});

  Future<Transaction?> getTransactionById(String id);

  Future<void> addTransaction(Transaction transaction);

  Future<void> updateTransaction(Transaction transaction);

  Future<void> deleteTransaction(String id);

  Future<double> getTotalAmount({
    required TransactionType transactionType,
    DateTime? startDate,
    DateTime? endDate,
  });
}

enum TransactionFilterPaymentMethod {
  all,
  tng,
  cash,
  bank,
}
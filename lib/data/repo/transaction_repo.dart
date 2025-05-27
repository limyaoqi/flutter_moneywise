import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/model/transaction_filter.dart';



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

enum TransactionFilterPaymentMethod { all, tng, cash, bank }

enum TransactionFilterDateMethod { all, daily, weekly, monthly }
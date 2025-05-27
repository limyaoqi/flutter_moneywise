import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/transaction_repo.dart';

class TransactionFilter {
  final TransactionFilterDateMethod? dateMethod;
  final String? dateRequired;
  final String? categoryId;
  final TransactionType? transactionType;
  final TransactionFilterPaymentMethod? paymentMethod;

  TransactionFilter({
    this.dateMethod = TransactionFilterDateMethod.all,
    this.dateRequired,
    this.categoryId,
    this.transactionType = TransactionType.income,
    this.paymentMethod = TransactionFilterPaymentMethod.all,
  });
  TransactionFilter copy({
    TransactionFilterDateMethod? dateMethod,
    String? dateRequired,
    String? categoryId,
    TransactionType? transactionType,
    TransactionFilterPaymentMethod? paymentMethod,
  }) {
    return TransactionFilter(
      dateMethod: dateMethod ?? this.dateMethod,
      dateRequired: dateRequired ?? this.dateRequired,
      categoryId: categoryId ?? this.categoryId,
      transactionType: transactionType ?? this.transactionType,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  String toString() {
    return 'TransactionFilter{dateMethod: $dateMethod, dateRequired: $dateRequired, categoryId: $categoryId, transactionType: $transactionType, paymentMethod: $paymentMethod}';
  }
}

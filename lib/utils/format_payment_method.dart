import 'package:moneywise/data/model/transaction.dart';

String formatPaymentMethod(TransactionPaymentMethod method) {
  switch (method) {
    case TransactionPaymentMethod.tng:
      return 'Touch n Go';
    case TransactionPaymentMethod.bank:
      return 'Bank Transfer';
    case TransactionPaymentMethod.cash:
      return 'Cash';
  }
}

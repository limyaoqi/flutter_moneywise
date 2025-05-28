import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/widget/transaction/transaction_base_screen.dart';

class ExpenseScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const ExpenseScreen({super.key, this.transactions = const []});

  @override
  Widget build(BuildContext context) {
    return TransactionBaseScreen(
      isIncome: false,
      transactions: transactions,
      title: 'Expense',
    );
  }
}

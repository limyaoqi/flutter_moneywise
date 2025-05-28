import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/widget/transaction/transaction_base_screen.dart';

class IncomeScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const IncomeScreen({super.key, this.transactions = const []});

  @override
  Widget build(BuildContext context) {
    return TransactionBaseScreen(
      isIncome: true,
      transactions: transactions,
      title: 'Income',
    );
  }
}

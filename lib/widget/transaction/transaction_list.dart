import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/widget/transaction/transaction_emptystate.dart';
import 'package:moneywise/widget/transaction/transaction_item.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key, this.isIncome, this.transactionList});
  final List<Transaction>? transactionList;
  final bool? isIncome;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final transactionList = widget.transactionList ?? [];
    if (transactionList.isEmpty) {
      return const TransactionEmptystate();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactionList.length,
      itemBuilder: (context, index) {
        final transaction = transactionList[index];
        return TransactionItem(transaction: transaction);
      },
    );
  }
}

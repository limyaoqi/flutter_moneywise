import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/category_repo.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/utils/color_utils.dart';
import 'package:moneywise/utils/format_payment_method.dart';
import 'package:moneywise/widget/transaction/transaction_emptystate.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key, this.isIncome, this.transactionList});
  final List<Transaction>? transactionList;
  final bool? isIncome;

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  @override
  Widget build(BuildContext context) {
    final transactionList = widget.transactionList ?? [];
    final isIncome = widget.isIncome ?? false;
    if (transactionList.isEmpty) {
      return const TransactionEmptystate();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: transactionList.length,
      itemBuilder: (context, index) {
        final transaction = transactionList[index];
        return _transactionItem(transaction);
      },
    );
  }
}

class _transactionItem extends StatelessWidget {
  _transactionItem(this.transaction);
  final Transaction transaction;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: 'RM');

  @override
  Widget build(BuildContext context) {
    final categoryRepo = CategoryRepoFirestore();
    return FutureBuilder<Category?>(
      future: categoryRepo.getCategoryById(transaction.categoryId),
      builder: (context, snapshot) {
        final category = snapshot.data;

        return Card(
          elevation: 2.0,
          margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            leading: _buildCategoryIcon(category),
            title: Text(
              transaction.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_dateFormat.format(transaction.date)),
                if (transaction.note != null && transaction.note!.isNotEmpty)
                  Text(
                    transaction.note!,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  'Payment: ${formatPaymentMethod(transaction.paymentMethod)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Text(
              _currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    transaction.transactionType == TransactionType.income
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            // onTap: () => _showTransactionDetails(transaction, category),
          ),
        );
      },
    );
  }
}

Widget _buildCategoryIcon(Category? category) {
  if (category == null) {
    return const CircleAvatar(
      radius: 20,
      backgroundColor: Colors.grey,
      child: Icon(Icons.category, color: Colors.white),
    );
  }

  return CircleAvatar(
    radius: 20,
    backgroundColor: getColorFromString(category.color),
    child:
        category.icon != null
            ? Image.asset(
              category.icon!,
              width: 24,
              height: 24,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.category, color: Colors.white);
              },
            )
            : const Icon(Icons.category, color: Colors.white),
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/data/repo/transaction_repo_firestore.dart';
import 'package:moneywise/nav/navigation.dart';
import 'package:moneywise/utils/color_utils.dart';
import 'package:moneywise/utils/format_payment_method.dart';
import 'package:moneywise/widget/dialogs/confirm_delete_dialog.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final categoryRepo = CategoryRepoFirestore();
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: 'RM');

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
                Text(dateFormat.format(transaction.date)),
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
              currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    transaction.transactionType == TransactionType.income
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            onTap:
                () => _showTransactionDetails(context, transaction, category),
            onLongPress: () => _showTransactionOptions(context, transaction),
          ),
        );
      },
    );
  }

  void _showTransactionDetails(
    BuildContext context,
    Transaction transaction,
    Category? category,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM');
    final dateFormat = DateFormat('dd MMM yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.85,
            expand: false,
            builder: (_, controller) {
              return SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(bottom: 20),
                      ),
                    ),
                    Center(
                      child: Text(
                        transaction.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            category != null
                                ? getColorFromString(category.color)
                                : Colors.grey,
                        child:
                            category?.icon != null
                                ? Image.asset(
                                  category!.icon!,
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.category,
                                      color: Colors.white,
                                      size: 40,
                                    );
                                  },
                                )
                                : const Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 40,
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        currencyFormat.format(transaction.amount),
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color:
                              transaction.transactionType ==
                                      TransactionType.income
                                  ? Colors.green
                                  : Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildDetailItem(
                      context,
                      'Category',
                      category?.name ?? 'Unknown',
                    ),
                    _buildDetailItem(
                      context,
                      'Date',
                      dateFormat.format(transaction.date),
                    ),
                    _buildDetailItem(
                      context,
                      'Payment Method',
                      formatPaymentMethod(transaction.paymentMethod),
                    ),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty)
                      _buildDetailItem(context, 'Note', transaction.note!),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToEdit(context, transaction);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmDelete(context, transaction);
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text('Edit Transaction'),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEdit(context, transaction);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Transaction'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(context, transaction);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancel'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _navigateToEdit(BuildContext context, Transaction transaction) {
    context.pushNamed(
      Screens.manage.name,
      queryParameters: {
        'isIncome':
            transaction.transactionType == TransactionType.income
                ? 'true'
                : 'false',
        'transactionId': transaction.id,
      },
    );
  }

  void _confirmDelete(BuildContext context, Transaction transaction) {
    ConfirmDeleteDialog.show(
      context: context,
      content: 'Are you sure you want to delete this transaction?',
      onConfirm: () => _deleteTransaction(context, transaction),
      confirmColor: Colors.red,
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    try {
      final transactionRepo = TransactionRepoFirestore();
      await transactionRepo.deleteTransaction(transaction.id!);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/transaction_repo_firestore.dart';
import 'package:moneywise/nav/navigation.dart';
import 'package:intl/intl.dart';

class TotalsWidget extends StatefulWidget {
  final User? user;

  const TotalsWidget({super.key, required this.user});

  @override
  State<TotalsWidget> createState() => _TotalsWidgetState();
}

class _TotalsWidgetState extends State<TotalsWidget> {
  final TransactionRepoFirestore _transactionRepo = TransactionRepoFirestore();
  double _totalIncome = 0;
  double _totalExpense = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTotals();
  }

  Future<void> _loadTotals() async {
    try {
      final income = await _transactionRepo.getTotalAmount(
        transactionType: TransactionType.income,
      );

      final expense = await _transactionRepo.getTotalAmount(
        transactionType: TransactionType.expense,
      );

      debugPrint('Total Income: $income, Total Expense: $expense');

      setState(() {
        _totalIncome = income;
        _totalExpense = expense;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading totals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToAnalytics() {
    context.pushNamed(Screens.analytics.name, extra: widget.user);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final currencyFormat = NumberFormat.currency(
      symbol: 'RM',
      decimalDigits: 0,
    );
    final balance = _totalIncome - _totalExpense;
    final isPositive = balance >= 0;

    return GestureDetector(
      onTap: _navigateToAnalytics,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          currencyFormat.format(balance),
          style: TextStyle(
            color: isPositive ? const Color(0xFF4CAF50) : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

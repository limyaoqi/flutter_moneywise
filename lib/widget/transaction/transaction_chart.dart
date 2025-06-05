import 'package:flutter/material.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/widget/chart/pie_chart_widget.dart';

class TransactionChart extends StatefulWidget {
  final List<Transaction> transactions;
  final bool isIncome;

  const TransactionChart({
    super.key,
    required this.transactions,
    required this.isIncome,
  });

  @override
  State<TransactionChart> createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  final CategoryRepoFirestore _categoryRepo = CategoryRepoFirestore();
  Map<String, Category> _categories = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final transactionType =
          widget.isIncome
              ? TransactionType.income.name
              : TransactionType.expense.name;
      final categories = await _categoryRepo.getCategoriesByType(
        transactionType,
      );

      setState(() {
        _categories = {for (var c in categories) c.id ?? 'unknown': c};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading categories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.transactions.isEmpty) {
      return Center(
        child: Text(
          'No ${widget.isIncome ? "income" : "expense"} data to display',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }

    // Group transactions by category and calculate total amount for each
    final categoryData = _getCategoryData();
    final chartTitle =
        widget.isIncome ? 'Income by Category' : 'Expenses by Category';
    final colors = _getChartColors();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChartWidget(
        data: categoryData,
        colors: colors,
        title: chartTitle,
      ),
    );
  }

  Map<String, double> _getCategoryData() {
    final Map<String, double> categoryTotals = {};

    for (final transaction in widget.transactions) {
      final categoryId = transaction.categoryId;
      final category = _categories[categoryId];
      final categoryName = category?.name ?? 'Uncategorized';
      final amount = transaction.amount;

      if (categoryTotals.containsKey(categoryName)) {
        categoryTotals[categoryName] = categoryTotals[categoryName]! + amount;
      } else {
        categoryTotals[categoryName] = amount;
      }
    }

    return categoryTotals;
  }

  List<Color> _getChartColors() {
    return widget.isIncome
        ? [
          AppColors.income,
          AppColors.income.withOpacity(0.9),
          AppColors.income.withOpacity(0.8),
          AppColors.income.withOpacity(0.7),
          AppColors.income.withOpacity(0.6),
          Colors.greenAccent,
          Colors.lightGreen,
          Colors.green[300]!,
          Colors.green[200]!,
        ]
        : [
          AppColors.expense,
          AppColors.expense.withOpacity(0.9),
          AppColors.expense.withOpacity(0.8),
          AppColors.expense.withOpacity(0.7),
          AppColors.expense.withOpacity(0.6),
          Colors.redAccent,
          Colors.red[300]!,
          Colors.orangeAccent,
          Colors.deepOrangeAccent,
        ];
  }
}

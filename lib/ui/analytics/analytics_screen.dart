import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/repo/transaction_repo_firestore.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/utils/format_payment_method.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final User? user;

  const AnalyticsScreen({super.key, required this.user});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final TransactionRepoFirestore _transactionRepo = TransactionRepoFirestore();
  final CategoryRepoFirestore _categoryRepo = CategoryRepoFirestore();

  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpense = 0;
  Map<String, double> _categoryBreakdown = {};
  Map<String, double> _paymentMethodBreakdown = {};
  Map<String, Category> _categories = {};

  String _selectedTimeRange = 'All Time';
  final List<String> _timeRanges = [
    'All Time',
    'This Month',
    'Last 30 Days',
    'This Year',
  ];

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DateTime? startDate;
      DateTime? endDate;

      // Calculate date range based on selection
      final now = DateTime.now();
      switch (_selectedTimeRange) {
        case 'This Month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Last 30 Days':
          startDate = now.subtract(const Duration(days: 30));
          endDate = now;
          break;
        case 'This Year':
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31);
          break;
        default: // All Time
          startDate = null;
          endDate = null;
      }

      // Get totals
      _totalIncome = await _transactionRepo.getTotalAmount(
        transactionType: TransactionType.income,
        startDate: startDate,
        endDate: endDate,
      );

      _totalExpense = await _transactionRepo.getTotalAmount(
        transactionType: TransactionType.expense,
        startDate: startDate,
        endDate: endDate,
      ); // Get all transactions for breakdown analysis
      final allTransactions = await _transactionRepo.getTransactions().first;

      // Filter transactions by date range if needed
      final filteredTransactions =
          allTransactions.where((transaction) {
            if (startDate == null || endDate == null) return true;
            return transaction.date.isAfter(
                  startDate.subtract(const Duration(days: 1)),
                ) &&
                transaction.date.isBefore(endDate.add(const Duration(days: 1)));
          }).toList();

      await _calculateBreakdowns(filteredTransactions);
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateBreakdowns(List<Transaction> transactions) async {
    // Load categories
    final incomeCategories = await _categoryRepo.getCategoriesByType(
      TransactionType.income.name,
    );
    final expenseCategories = await _categoryRepo.getCategoriesByType(
      TransactionType.expense.name,
    );

    _categories = {};
    for (var category in [...incomeCategories, ...expenseCategories]) {
      _categories[category.id ?? ''] = category;
    }

    // Calculate category breakdown
    Map<String, double> categoryTotals = {};
    Map<String, double> paymentTotals = {};

    for (var transaction in transactions) {
      // Category breakdown
      final category = _categories[transaction.categoryId];
      final categoryName = category?.name ?? 'Uncategorized';
      categoryTotals[categoryName] =
          (categoryTotals[categoryName] ?? 0) + transaction.amount;

      // Payment method breakdown
      final paymentMethod = formatPaymentMethod(transaction.paymentMethod);
      paymentTotals[paymentMethod] =
          (paymentTotals[paymentMethod] ?? 0) + transaction.amount;
    }

    setState(() {
      _categoryBreakdown = categoryTotals;
      _paymentMethodBreakdown = paymentTotals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'RM');
    final balance = _totalIncome - _totalExpense;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time Range Selector
                    _buildTimeRangeSelector(),
                    const SizedBox(height: 20),

                    // Summary Cards
                    _buildSummaryCards(currencyFormat, balance),
                    const SizedBox(height: 24),

                    // Category Breakdown
                    _buildSectionTitle('Breakdown by Category'),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(_categoryBreakdown, currencyFormat),
                    const SizedBox(height: 24),

                    // Payment Method Breakdown
                    _buildSectionTitle('Breakdown by Payment Method'),
                    const SizedBox(height: 12),
                    _buildBreakdownCard(
                      _paymentMethodBreakdown,
                      currencyFormat,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _timeRanges.map((range) {
                  final isSelected = _selectedTimeRange == range;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTimeRange = range;
                      });
                      _loadAnalytics();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        range,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(NumberFormat currencyFormat, double balance) {
    return Column(
      children: [
        // Balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    balance >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: balance >= 0 ? Colors.green : Colors.red,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Net Balance',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(balance),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: balance >= 0 ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Income and Expense cards
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Income',
                currencyFormat.format(_totalIncome),
                AppColors.income,
                Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Total Expenses',
                currencyFormat.format(_totalExpense),
                AppColors.expense,
                Icons.trending_down,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildBreakdownCard(
    Map<String, double> breakdown,
    NumberFormat currencyFormat,
  ) {
    if (breakdown.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: AppColors.textLight, fontSize: 16),
          ),
        ),
      );
    }

    // Sort by amount (descending)
    final sortedEntries =
        breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            sortedEntries.map((entry) {
              final percentage =
                  breakdown.values.fold(0.0, (sum, value) => sum + value) > 0
                      ? (entry.value /
                              breakdown.values.fold(
                                0.0,
                                (sum, value) => sum + value,
                              )) *
                          100
                      : 0.0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      currencyFormat.format(entry.value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

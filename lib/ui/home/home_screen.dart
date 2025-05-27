import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/model/transaction_filter.dart';
import 'package:moneywise/data/repo/transaction_repo.dart';
import 'package:moneywise/data/repo/transaction_repo_firestore.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/ui/category/category_screen.dart';
import 'package:moneywise/ui/home/expense/expense_screen.dart';
import 'package:moneywise/ui/home/income/income_screen.dart';
import 'package:moneywise/widget/filterbar/payment_filter_bar.dart';
import 'package:moneywise/widget/filterbar/time_filter_bar.dart';
import 'package:moneywise/widget/profile/user_avatar.dart';

class HomeScreen extends StatefulWidget {
  final User? user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final TransactionRepo _transactionRepo = TransactionRepoFirestore();

  // Current filter state
  TransactionFilterPaymentMethod _currentPaymentMethod =
      TransactionFilterPaymentMethod.all;
  TimeFilterType _currentTimeFilterType = TimeFilterType.all;
  DateTime? _currentDateTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TransactionFilter _buildCurrentFilter() {
    TransactionType? transactionType;
    if (_selectedIndex == 0) {
      transactionType = TransactionType.income;
    } else if (_selectedIndex == 1) {
      transactionType = TransactionType.expense;
    } else {
      // For categories tab, we don't need a transaction type
      return TransactionFilter();
    }

    // Create the appropriate filter based on current selections
    TransactionFilter filter = TransactionFilter(
      transactionType: transactionType,
      paymentMethod: _currentPaymentMethod,
      dateMethod: TransactionFilterDateMethod.all,
    );

    // Add date filtering if applicable
    if (_currentTimeFilterType != TimeFilterType.all &&
        _currentDateTime != null) {
      switch (_currentTimeFilterType) {
        case TimeFilterType.daily:
          filter = TransactionFilter(
            transactionType: transactionType,
            paymentMethod: _currentPaymentMethod,
            dateMethod: TransactionFilterDateMethod.daily,
            dateRequired: _currentDateTime!.toIso8601String().substring(
              0,
              10,
            ), // YYYY-MM-DD
          );
          break;
        case TimeFilterType.monthly:
          filter = TransactionFilter(
            transactionType: transactionType,
            paymentMethod: _currentPaymentMethod,
            dateMethod: TransactionFilterDateMethod.monthly,
            dateRequired:
                '${_currentDateTime!.year}-${_currentDateTime!.month.toString().padLeft(2, '0')}', // YYYY-MM
          );
          break;
        case TimeFilterType.yearly:
          filter = TransactionFilter(
            transactionType: transactionType,
            paymentMethod: _currentPaymentMethod,
            dateMethod:
                TransactionFilterDateMethod
                    .weekly, // Using weekly for yearly as per implementation
            dateRequired: _currentDateTime!.year.toString(),
          );
          break;
        case TimeFilterType.all:
          // Already handled with default filter
          break;
      }
    }

    debugPrint(
      'Filter: $filter | transactionType: ${transactionType.toString()}',
    );

    return filter;
  }

  @override
  Widget build(BuildContext context) {
    final filter = _buildCurrentFilter();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'MoneyWise',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: UserAvatar(user: widget.user),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bars
          Container(
            margin: const EdgeInsets.all(8.0),
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
                // Payment Type Filter
                PaymentFilterBar(
                  onFilterChanged: (filterValue) {
                    setState(() {
                      // Convert string filter to enum
                      switch (filterValue) {
                        case 'TNG':
                          _currentPaymentMethod =
                              TransactionFilterPaymentMethod.tng;
                          break;
                        case 'Cash':
                          _currentPaymentMethod =
                              TransactionFilterPaymentMethod.cash;
                          break;
                        case 'Bank':
                          _currentPaymentMethod =
                              TransactionFilterPaymentMethod.bank;
                          break;
                        case 'All':
                        default:
                          _currentPaymentMethod =
                              TransactionFilterPaymentMethod.all;
                      }
                    });
                  },
                ),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary.withAlpha(50),
                ),

                // Time Filter
                TimeFilterBar(
                  onFilterChanged: (filterType, dateTime) {
                    setState(() {
                      _currentTimeFilterType = filterType;
                      _currentDateTime = dateTime;
                    });
                  },
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child:
                _selectedIndex == 2
                    ? const CategoriesScreen()
                    : StreamBuilder<List<Transaction>>(
                      stream: _transactionRepo.getTransactions(filter: filter),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          debugPrint(
                            'Error loading transactions: ${snapshot.error}',
                          );
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text('Error: ${snapshot.error}'),
                              ],
                            ),
                          );
                        }

                        final transactions = snapshot.data ?? [];
                        debugPrint(
                          'Received ${transactions.length} transactions',
                        );

                        return TabBarView(
                          controller: _tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            IncomeScreen(
                              transactions:
                                  _selectedIndex == 0 ? transactions : [],
                            ),
                            ExpenseScreen(
                              transactions:
                                  _selectedIndex == 1 ? transactions : [],
                            ),
                            const CategoriesScreen(), // This won't actually be shown
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _tabController.animateTo(index);
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          backgroundColor: AppColors.cardBackground,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Income',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.money_off),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category),
              label: 'Categories',
            ),
          ],
        ),
      ),
    );
  }
}

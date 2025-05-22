import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
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
  // Store filtered transactions for UI update (to be used later)
  // ignore: unused_field
  List<Transaction> _filteredTransactions = [];

  void onFilterChanged(TransactionFilter filter) {
    _transactionRepo.getTransactions(filter: filter).listen((transactions) {
      setState(() {
        _filteredTransactions = transactions;
        // Here you would update your UI with the filtered transactions
      });
    });
  }

  // Method to build and apply the filter from current selections
  void _applyFilters() {
    final TransactionType transactionType =
        _selectedIndex == 0 ? TransactionType.income : TransactionType.expense;

    String? dateRequired;
    TransactionFilterDateMethod? dateMethod;

    // Convert TimeFilterType to TransactionFilterDateMethod and format date
    switch (_currentTimeFilterType) {
      case TimeFilterType.daily:
        dateMethod = TransactionFilterDateMethod.daily;
        if (_currentDateTime != null) {
          dateRequired = _currentDateTime!.toIso8601String().split('T')[0];
        }
        break;
      case TimeFilterType.monthly:
        dateMethod = TransactionFilterDateMethod.monthly;
        if (_currentDateTime != null) {
          dateRequired =
              "${_currentDateTime!.year}-${_currentDateTime!.month.toString().padLeft(2, '0')}";
        }
        break;
      case TimeFilterType.yearly:
        dateMethod =
            TransactionFilterDateMethod
                .monthly; // Using monthly for year filtering
        if (_currentDateTime != null) {
          dateRequired = "${_currentDateTime!.year}";
        }
        break;
      case TimeFilterType.all:
        dateMethod = TransactionFilterDateMethod.all;
        dateRequired = null;
    } 
    // Create and apply the filter
    final filter = TransactionFilter(
      transactionType: transactionType,
      paymentMethod: _currentPaymentMethod,
      dateMethod: dateMethod,
      dateRequired: dateRequired,
    );

    onFilterChanged(filter);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });

      // Apply filters when switching between Income/Expense tabs
      // Only apply if we're on Income or Expense tabs (0 or 1)
      if (_selectedIndex < 2) {
        _applyFilters();
      }
    });

    // Initialize with default filters
    Future.microtask(() => _applyFilters());
  }

  // Dispose the TabController when the widget is removed from the widget tree
  // to prevent memory leaks.
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // User profile icon/avatar using the separate widget
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
                  onFilterChanged: (filter) {
                    setState(() {
                      // Convert string filter to enum
                      switch (filter) {
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
                    _applyFilters();
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
                    _applyFilters();
                  },
                ),
              ],
            ),
          ), // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                IncomeScreen(),
                ExpenseScreen(),
                CategoriesScreen(),
              ],
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

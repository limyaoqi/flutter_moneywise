import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/ui/category/categories_screen.dart';
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
                const PaymentFilterBar(),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.primary.withAlpha(50),
                ),

                // Time Filter
                const TimeFilterBar(),
              ],
            ),
          ),

          // Main Content
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

import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/widget/transaction/transaction_list.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Transaction> _dummyTransactions = [
    Transaction(
      id: '1',
      title: 'Grocery Shopping',
      amount: 150.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: "02fd4032-225d-43e3-a4eb-5c6cd4fda544",
      paymentMethod: TransactionPaymentMethod.cash,
      note: 'Weekly grocery shopping',
      transactionType: TransactionType.expense,
    ),
    Transaction(
      id: '2',
      title: 'Utility Bill',
      amount: 75.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      categoryId: "7d5b2dc5-bdbc-4a1f-89ee-9c1c389911b9",
      paymentMethod: TransactionPaymentMethod.bank,
      note: 'Monthly utility bill payment',
      transactionType: TransactionType.expense,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income List', icon: Icon(Icons.list)),
            Tab(text: 'Add Income', icon: Icon(Icons.add)),
            Tab(text: 'Income Chart', icon: Icon(Icons.pie_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransactionList(isIncome: false, transactionList: _dummyTransactions),
          Center(child: Text('Add Income')),
          Center(child: Text('Income Chart')),
        ],
      ),
    );
  }
}
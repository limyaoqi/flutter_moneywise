import 'package:flutter/material.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/widget/transaction/transaction_list.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Transaction> _dummyTransactions = [
    Transaction(
      id: '1',
      title: 'Freelance Project',
      amount: 1500.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      categoryId: "02fd4032-225d-43e3-a4eb-5c6cd4fda544",
      paymentMethod: TransactionPaymentMethod.bank,
      note: 'Payment from Upwork client',
      transactionType: TransactionType.income,
    ),
    Transaction(
      id: '2',
      title: 'Salary',
      amount: 3200.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
      categoryId: "7d5b2dc5-bdbc-4a1f-89ee-9c1c389911b9",
      paymentMethod: TransactionPaymentMethod.cash,
      note: 'Monthly salary',
      transactionType: TransactionType.income,
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
          TransactionList(isIncome: true, transactionList: _dummyTransactions),
          Center(child: Text('Add Income')),
          Center(child: Text('Income Chart')),
        ],
      ),
    );
  }
}

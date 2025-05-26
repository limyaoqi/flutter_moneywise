import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/nav/navigation.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/widget/transaction/transaction_list.dart';

class TransactionBaseScreen extends StatefulWidget {
  final bool isIncome;
  final List<Transaction> transactions;
  final String title;

  const TransactionBaseScreen({
    super.key,
    required this.isIncome,
    required this.transactions,
    required this.title,
  });

  @override
  State<TransactionBaseScreen> createState() => _TransactionBaseScreenState();
}

class _TransactionBaseScreenState extends State<TransactionBaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.isIncome ? AppColors.income : AppColors.expense;
    final listTabLabel = "${widget.title} List";
    final chartTabLabel = "${widget.title} Chart";

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            Text(widget.title),
            const Spacer(),
            SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                onPressed: () {
                  context.pushNamed(
                    Screens.manage.name,
                    queryParameters: {'isIncome': widget.isIncome.toString()},
                  );
                },
                child: const Icon(Icons.add, size: 24),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: listTabLabel, icon: const Icon(Icons.list)),
            Tab(text: chartTabLabel, icon: const Icon(Icons.pie_chart)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TransactionList(
            isIncome: widget.isIncome,
            transactionList: widget.transactions,
          ),
          Center(child: Text('${widget.title} Chart')),
        ],
      ),
    );
  }
}

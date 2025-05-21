import 'package:flutter/material.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
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
        children: const [
          Center(child: Text('Income List')),
          Center(child: Text('Add Income')),
          Center(child: Text('Income Chart')),
        ],
      ),
    );
  }
}
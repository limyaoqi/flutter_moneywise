import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/model/transaction.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:moneywise/data/repo/transaction_repo_firestore.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/utils/color_utils.dart';

class ManageScreen extends StatefulWidget {
  final bool isIncome;
  final String? transactionId;
  const ManageScreen({super.key, this.isIncome = false, this.transactionId});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  final transactionRepo = TransactionRepoFirestore();
  final categoryRepo = CategoryRepoFirestore();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final _dateController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isIncome = false; // Local state to track the current transaction type
  Transaction? _transaction;
  List<Category> _categories = [];
  Category? _selectedCategory;
  DateTime? _selectedDate;
  TransactionPaymentMethod _selectedPaymentMethod =
      TransactionPaymentMethod.cash;

  @override
  void initState() {
    _isIncome = widget.isIncome; // Initialize with the widget property
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _categories = await categoryRepo.getCategoriesByType(
        _isIncome ? TransactionType.income : TransactionType.expense,
      );

      if (widget.transactionId != null) {
        await _loadTransactionData();
      } else {
        // Set _selectedDate to current date for new transactions
        _selectedDate = DateTime.now();
        _dateController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";

        // Reset selected category when changing types
        _selectedCategory = null;

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTransactionData() async {
    try {
      _transaction = await transactionRepo.getTransactionById(
        widget.transactionId!,
      );
      if (_transaction != null) {
        _titleController.text = _transaction!.title;
        _amountController.text = _transaction!.amount.toString();
        _noteController.text = _transaction!.note ?? '';
        _selectedDate = _transaction!.date;
        _selectedPaymentMethod = _transaction!.paymentMethod;
        _selectedCategory = await categoryRepo.getCategoryById(
          _transaction!.categoryId,
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading transaction: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (_titleController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    final transaction = Transaction(
      id: widget.transactionId ?? null,
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      date: _selectedDate!,
      categoryId: _selectedCategory!.id,
      paymentMethod: _selectedPaymentMethod,
      note: _noteController.text.isEmpty ? null : _noteController.text,
      transactionType:
          _isIncome ? TransactionType.income : TransactionType.expense,
    );

    try {
      if (widget.transactionId == null) {
        await transactionRepo.addTransaction(transaction);
      } else {
        await transactionRepo.updateTransaction(transaction);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving transaction: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Helper method to change transaction type
  void _changeTransactionType(bool isIncome) {
    if (_isIncome != isIncome) {
      setState(() {
        _isIncome = isIncome;
        _selectedCategory = null; // Reset selected category when changing types
      });
      _loadData(); // Reload categories based on the new type
    }
  }

  // Helper method to get category color
 

  @override
  Widget build(BuildContext context) {
    final screenTitle =
        _isIncome
            ? (widget.transactionId != null ? 'Edit Income' : 'Add Income')
            : (widget.transactionId != null ? 'Edit Expense' : 'Add Expense');

    final buttonColor = _isIncome ? AppColors.income : AppColors.expense;

    return Scaffold(
      appBar: AppBar(
        title: Text(screenTitle), // Remove the GestureDetector
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false),
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
                    // Title Field
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Amount Field
                    TextField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16.0), // Transaction Type Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transaction Type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Expense'),
                                value: false,
                                groupValue: _isIncome,
                                onChanged: (value) {
                                  if (value != null) {
                                    _changeTransactionType(value);
                                  }
                                },
                                activeColor: AppColors.expense,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<bool>(
                                title: const Text('Income'),
                                value: true,
                                groupValue: _isIncome,
                                onChanged: (value) {
                                  if (value != null) {
                                    _changeTransactionType(value);
                                  }
                                },
                                activeColor: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Category Selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _categories.isEmpty
                              ? const Center(
                                  child: Text('No categories available'),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(8),
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: _categories.length,
                                  itemBuilder: (context, index) {
                                    final category = _categories[index];
                                    final isSelected = _selectedCategory?.id == category.id;

                                    // Get color from category
                                    Color categoryColor = getColorFromString(category.color);

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? categoryColor : Colors.transparent,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          color: isSelected ? categoryColor.withOpacity(0.1) : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: categoryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Image.asset(
                                                  category.icon ?? '',
                                                  width: 24,
                                                  height: 24,
                                                  color: Colors.white,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(
                                                      Icons.category,
                                                      color: Colors.white,
                                                      size: 24,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              category.name,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isSelected ? categoryColor : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Date Picker
                    GestureDetector(
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _dateController.text =
                                "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Payment Method Selection
                    const Text(
                      'Payment Method',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      children:
                          TransactionPaymentMethod.values.map((method) {
                            return ChoiceChip(
                              label: Text(method.toString().split('.').last),
                              selected: _selectedPaymentMethod == method,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedPaymentMethod = method;
                                  });
                                }
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16.0),

                    // Note Field
                    TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24.0),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitTransaction,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isSubmitting
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  widget.transactionId != null
                                      ? 'Update'
                                      : 'Save',
                                ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

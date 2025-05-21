import 'package:flutter/material.dart';
import 'package:moneywise/ui/category/category_list.dart';

class CategoryAdd extends StatefulWidget {
  const CategoryAdd({super.key});

  @override
  State<CategoryAdd> createState() => _CategoryAddState();
}

class _CategoryAddState extends State<CategoryAdd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
  String? _selectedIcon; // To store the selected icon path
  String? _selectedType = 'expense'; // Default category type
  // Map of icons with their file paths
  final Map<String, String> _availableIcons = {
    'Food': 'assets/icons/categories/food.png',
    'Transportation': 'assets/icons/categories/transportation.png',
    'Entertainment': 'assets/icons/categories/entertainment.png',
    'Shopping': 'assets/icons/categories/shopping-cart.png',
    'Bills': 'assets/icons/categories/bill.png',
    'Healthcare': 'assets/icons/categories/healthcare.png',
    'Education': 'assets/icons/categories/education.png',
    'Salary': 'assets/icons/categories/salary.png',
    'Business': 'assets/icons/categories/business.png',
    'Investment': 'assets/icons/categories/investment.png',
  };

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },            ),
            const SizedBox(height: 20),
            
            // Category Type Selection
            const Text(
              'Category Type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Expense'),
                    value: 'expense',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Income'),
                    value: 'income',
                    groupValue: _selectedType,
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            // Icon Selection
            const SizedBox(height: 20),
            const Text(
              'Category Icon',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconName = _availableIcons.keys.elementAt(index);
                  final iconPath = _availableIcons.values.elementAt(index);
                  final isSelected = iconPath == _selectedIcon;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconPath;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? _selectedColor : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? _selectedColor.withOpacity(0.1) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            iconPath,
                            width: 32,
                            height: 32,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 32,
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            iconName,
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? _selectedColor : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Color Selection
            const SizedBox(height: 20),
            const Text(
              'Category Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    _availableColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  _selectedColor == color
                                      ? Colors.black
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            const SizedBox(height: 30),            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (_selectedIcon == null) {
                      // Show a message if no icon is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an icon')),
                      );
                      return;
                    }
                    
                    // Here you would normally save the category to your database
                    // For now, we'll just show a success message
                    
                    // Create a category object with all the selected values
                    final newCategory = {
                      'name': _nameController.text,
                      'color': _selectedColor,  // You might want to convert this to a string format
                      'type': _selectedType,
                      'icon': _selectedIcon,
                    };
                    
                    print('New Category: $newCategory'); // For debugging
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category added')),
                    );
                    
                    // Reset form
                    _nameController.clear();
                    setState(() {
                      _selectedIcon = null;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Add Category'),
              ),
            ),          ],
          ),
        ),
      ),
    );
  }
}

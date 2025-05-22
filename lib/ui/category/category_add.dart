import 'package:flutter/material.dart';
import 'package:moneywise/data/model/category.dart';
import 'package:moneywise/data/repo/category_repo_firestore.dart';
import 'package:uuid/uuid.dart';

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
  String _selectedType = 'expense'; // Default category type
  final CategoryRepoFirestore _categoryRepo = CategoryRepoFirestore();
  final _uuid = Uuid();

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

  // Map to convert Color object to string name
  String _colorToString(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.pink) return 'pink';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.deepPurple) return 'deepPurple';
    if (color == Colors.indigo) return 'indigo';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.lightBlue) return 'lightBlue';
    if (color == Colors.cyan) return 'cyan';
    if (color == Colors.teal) return 'teal';
    if (color == Colors.green) return 'green';
    if (color == Colors.lightGreen) return 'lightGreen';
    if (color == Colors.lime) return 'lime';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.amber) return 'amber';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.deepOrange) return 'deepOrange';
    if (color == Colors.brown) return 'brown';
    if (color == Colors.grey) return 'grey';
    return 'blue'; // Default color
  }

  void _selectIcon(String iconPath) {
    setState(() {
      _selectedIcon = iconPath;
    });
  }

  void _selectColor(Color color) {
    setState(() {
      _selectedColor = color;
    });
  }

  void _selectType(String? value) {
    setState(() {
      _selectedType = value!;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedIcon == null) {
        // Show a message if no icon is selected
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select an icon')));
        return;
      }

      // Create a category object with all the selected values
      final newCategory = Category(
        id: _uuid.v4(),
        name: _nameController.text,
        color: _colorToString(_selectedColor),
        icon: _selectedIcon!,
        type: _selectedType,
      );

      // print('New Category: $newCategory'); // For debugging

      // Add the category to Firestore
      _categoryRepo
          .addCategory(newCategory)
          .then((_) {
            // Show success message
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Category added')));

            // Reset form
            _nameController.clear();
            setState(() {
              _selectedIcon = null;
            });
          })
          .catchError((error) {
            // Handle any errors here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding category: $error')),
            );
          });
    }
  }

  Widget _buildCategoryNameField() {
    return TextFormField(
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
      },
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category Icon',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _availableIcons.length,
            itemBuilder: (context, index) {
              final iconName = _availableIcons.keys.elementAt(index);
              final iconPath = _availableIcons.values.elementAt(index);
              final isSelected = iconPath == _selectedIcon;

              return GestureDetector(
                onTap: () => _selectIcon(iconPath),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color:
                        isSelected
                            ? Color.fromRGBO(
                              _selectedColor.red,
                              _selectedColor.green,
                              _selectedColor.blue,
                              0.1,
                            )
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                        ),
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
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    onTap: () => _selectColor(color),
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
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                onChanged: _selectType,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Income'),
                value: 'income',
                groupValue: _selectedType,
                onChanged: _selectType,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text('Add Category'),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryNameField(),
              const SizedBox(height: 20),
              _buildIconSelector(),
              const SizedBox(height: 20),
              _buildColorSelector(),
              const SizedBox(height: 20),
              _buildTypeSelector(),
              const SizedBox(height: 30),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

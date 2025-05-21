import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';

class PaymentFilterBar extends StatefulWidget {
  final Function(String)? onFilterChanged;
  const PaymentFilterBar({super.key, this.onFilterChanged});

  @override
  State<PaymentFilterBar> createState() => _PaymentFilterBarState();
}

class _PaymentFilterBarState extends State<PaymentFilterBar> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'TNG', 'Cash', 'Bank'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(filter),
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      if (widget.onFilterChanged != null) {
                        widget.onFilterChanged!(filter);
                      }
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? AppColors.primary : AppColors.textDark,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

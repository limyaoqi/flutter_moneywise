import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';

/// A widget for selecting a month and year combination.
///
/// Displays two dropdown buttons side by side - one for month selection and
/// one for year selection. Changes are communicated via the callbacks.
class MonthlySelector extends StatelessWidget {
  /// The currently selected month (1-12)
  final int selectedMonth;

  /// The currently selected year
  final int selectedYear;

  /// Callback that is called when a month is selected
  final Function(int) onMonthSelected;

  /// Callback that is called when a year is selected
  final Function(int) onYearSelected;

  /// The earliest year that can be selected
  final int startYear;

  /// Number of years to display in the dropdown
  final int yearCount;

  /// Month abbreviations to display in the dropdown
  final List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  MonthlySelector({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthSelected,
    required this.onYearSelected,
    this.startYear = 2020,
    this.yearCount = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Month dropdown
        _buildMonthDropdown(),
        const SizedBox(width: 16.0),
        // Year dropdown
        _buildYearDropdown(),
      ],
    );
  }

  /// Builds the month selection dropdown
  Widget _buildMonthDropdown() {
    return DropdownButton<int>(
      value: selectedMonth,
      underline: Container(height: 2, color: AppColors.primary),
      onChanged: (int? newValue) {
        if (newValue != null) {
          onMonthSelected(newValue);
        }
      },
      items: List.generate(
        12,
        (index) => DropdownMenuItem<int>(
          value: index + 1, // Months are 1-indexed
          child: Text(months[index]),
        ),
      ),
    );
  }

  /// Builds the year selection dropdown
  Widget _buildYearDropdown() {
    return DropdownButton<int>(
      value: selectedYear,
      underline: Container(height: 2, color: AppColors.primary),
      onChanged: (int? newValue) {
        if (newValue != null) {
          onYearSelected(newValue);
        }
      },
      items: List.generate(
        yearCount,
        (index) => DropdownMenuItem<int>(
          value: startYear + index,
          child: Text((startYear + index).toString()),
        ),
      ),
    );
  }
}

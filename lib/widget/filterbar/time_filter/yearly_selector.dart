import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';

/// A widget for selecting a specific year.
///
/// Displays a dropdown button with a range of years to select from.
/// Selection changes are communicated via the callback.
class YearlySelector extends StatelessWidget {
  /// The currently selected year
  final int selectedYear;

  /// Callback that is called when a year is selected
  final Function(int) onYearSelected;

  /// The earliest year that can be selected
  final int startYear;

  /// Number of years to display in the dropdown
  final int yearCount;

  const YearlySelector({
    super.key,
    required this.selectedYear,
    required this.onYearSelected,
    this.startYear = 2020,
    this.yearCount = 11,
  });

  @override
  Widget build(BuildContext context) {
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

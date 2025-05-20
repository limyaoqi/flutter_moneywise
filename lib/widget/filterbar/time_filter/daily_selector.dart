import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneywise/theme/app_colors.dart';

/// A widget for selecting a specific date.
///
/// Displays a button that opens a date picker when tapped. Once a date is selected,
/// it is displayed in a formatted way and the selection is communicated via the callback.
class DailySelector extends StatelessWidget {
  /// The currently selected date, can be null if no date is selected yet
  final DateTime? selectedDate;

  /// Callback that is called when a date is selected
  final Function(DateTime) onDateSelected;

  /// The earliest date that can be selected
  final DateTime? firstDate;

  /// The latest date that can be selected
  final DateTime? lastDate;

  const DailySelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    // Return an InkWell that opens a date picker when tapped
    return InkWell(
      onTap: () async {
        // Show date picker and wait for user selection
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2030),
        );

        // If a date was selected and it's different from the current selection,
        // notify the parent via the callback
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      // Display a container with the selected date or placeholder text
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show either the selected date formatted or a placeholder text
            Text(
              selectedDate == null
                  ? 'Select Date'
                  : dateFormat.format(selectedDate!),
              style: const TextStyle(color: AppColors.primary),
            ),
            const SizedBox(width: 8.0),
            // Calendar icon for better UX indication
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 16.0,
            ),
          ],
        ),
      ),
    );
  }
}

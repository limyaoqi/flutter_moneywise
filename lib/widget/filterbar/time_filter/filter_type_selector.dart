import 'package:flutter/material.dart';
import 'package:moneywise/theme/app_colors.dart';
import 'package:moneywise/widget/filterbar/time_filter_bar.dart';

/// A widget for selecting a time filter type (All, Daily, Monthly, Yearly).
///
/// Displays a horizontal scrollable row of filter chips, allowing the user to
/// select a filter type. The selection is communicated via the callback.
class FilterTypeSelector extends StatelessWidget {
  /// The currently selected filter type
  final TimeFilterType selectedFilterType;

  /// Callback that is called when a filter type is selected
  final Function(TimeFilterType) onFilterTypeSelected;

  /// List of filter types and their labels
  final List<Map<String, dynamic>> filters;

  const FilterTypeSelector({
    super.key,
    required this.selectedFilterType,
    required this.onFilterTypeSelected,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            filters.map((filter) {
              // Determine if this filter is the selected one
              final isSelected = selectedFilterType == filter['type'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(filter['label']),
                  onSelected: (_) {
                    // Notify parent of the selection change
                    onFilterTypeSelected(filter['type']);
                  },
                  // Styling for the filter chip
                  selectedColor: AppColors.primary.withOpacity(0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textDark,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}

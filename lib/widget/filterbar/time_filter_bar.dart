import 'package:flutter/material.dart';
import 'package:moneywise/widget/filterbar/time_filter/daily_selector.dart';
import 'package:moneywise/widget/filterbar/time_filter/filter_type_selector.dart';
import 'package:moneywise/widget/filterbar/time_filter/monthly_selector.dart';
import 'package:moneywise/widget/filterbar/time_filter/yearly_selector.dart';

/// Enum representing the different types of time filters available
enum TimeFilterType { all, daily, monthly, yearly }

/// A widget that provides time-based filtering options.
///
/// This widget allows users to filter data by different time periods:
/// - All time (no filter)
/// - Daily (specific date)
/// - Monthly (specific month and year)
/// - Yearly (specific year)
class TimeFilterBar extends StatefulWidget {
  /// Callback that is triggered when the filter selection changes.
  /// Provides the selected filter type and the corresponding DateTime.
  final Function(TimeFilterType, DateTime?)? onFilterChanged;

  const TimeFilterBar({super.key, this.onFilterChanged});

  @override
  State<TimeFilterBar> createState() => _TimeFilterBarState();
}

class _TimeFilterBarState extends State<TimeFilterBar> {
  // Current filter selections
  TimeFilterType _selectedFilterType = TimeFilterType.all;
  DateTime? _selectedDate;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // List of filter types and their labels
  final List<Map<String, dynamic>> _filters = [
    {'type': TimeFilterType.all, 'label': 'All'},
    {'type': TimeFilterType.daily, 'label': 'Daily'},
    {'type': TimeFilterType.monthly, 'label': 'Monthly'},
    {'type': TimeFilterType.yearly, 'label': 'Yearly'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.transparent,
      child: Column(
        children: [
          // Filter type selection chips (All, Daily, Monthly, Yearly)
          FilterTypeSelector(
            selectedFilterType: _selectedFilterType,
            onFilterTypeSelected: _handleFilterTypeSelected,
            filters: _filters,
          ),

          // Date/month/year selector based on selected filter type
          if (_selectedFilterType != TimeFilterType.all)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: _buildDateSelector(),
            ),
        ],
      ),
    );
  }

  /// Handles when a user selects a different filter type
  void _handleFilterTypeSelected(TimeFilterType filterType) {
    setState(() {
      _selectedFilterType = filterType;

      // Initialize date selections when switching to daily filter
      if (_selectedFilterType == TimeFilterType.daily &&
          _selectedDate == null) {
        _selectedDate = DateTime.now();
      }
    });
    _notifyFilterChanged();
  }

  /// Builds the appropriate selector widget based on the selected filter type
  Widget _buildDateSelector() {
    switch (_selectedFilterType) {
      case TimeFilterType.daily:
        return DailySelector(
          selectedDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            _notifyFilterChanged();
          },
        );

      case TimeFilterType.monthly:
        return MonthlySelector(
          selectedMonth: _selectedMonth,
          selectedYear: _selectedYear,
          onMonthSelected: (month) {
            setState(() {
              _selectedMonth = month;
            });
            _notifyFilterChanged();
          },
          onYearSelected: (year) {
            setState(() {
              _selectedYear = year;
            });
            _notifyFilterChanged();
          },
        );

      case TimeFilterType.yearly:
        return YearlySelector(
          selectedYear: _selectedYear,
          onYearSelected: (year) {
            setState(() {
              _selectedYear = year;
            });
            _notifyFilterChanged();
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Notifies parent widget about filter changes
  void _notifyFilterChanged() {
    if (widget.onFilterChanged != null) {
      DateTime? selectedDateTime;

      // Convert the selected filter type and values into an appropriate DateTime
      switch (_selectedFilterType) {
        case TimeFilterType.daily:
          selectedDateTime = _selectedDate;
          break;
        case TimeFilterType.monthly:
          selectedDateTime = DateTime(_selectedYear, _selectedMonth);
          break;
        case TimeFilterType.yearly:
          selectedDateTime = DateTime(_selectedYear);
          break;
        default:
          selectedDateTime = null;
          break;
      }

      widget.onFilterChanged!(_selectedFilterType, selectedDateTime);
    }
  }
}

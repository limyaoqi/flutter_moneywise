import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;
  final List<Color>? colors;
  final String title;

  const PieChartWidget({
    super.key,
    required this.data,
    this.colors,
    required this.title,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;
  final _currencyFormat = NumberFormat.currency(symbol: 'RM');

  @override
  Widget build(BuildContext context) {
    // Handle empty data
    if (widget.data.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No data available',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate available height and distribute space
            final availableHeight = constraints.maxHeight;
            final titleHeight = 30.0;
            final spacingHeight = 16.0;
            final legendHeight =
                widget.data.length * 28.0 + 20.0; // Estimate legend height
            final chartHeight = (availableHeight -
                    titleHeight -
                    spacingHeight -
                    legendHeight)
                .clamp(120.0, 180.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Pie Chart with flexible sizing
                SizedBox(
                  height: chartHeight,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius:
                          chartHeight * 0.2, // Responsive center space
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex =
                                pieTouchResponse
                                    .touchedSection!
                                    .touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Legend with scrollable container if needed
                Flexible(child: _buildLegend()),
              ],
            );
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    final total = widget.data.values.fold(0.0, (sum, value) => sum + value);
    final sortedEntries =
        widget.data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final defaultColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final dataEntry = entry.value;
      final isTouched = index == touchedIndex;
      final percentage = total > 0 ? (dataEntry.value / total * 100) : 0;

      final color =
          widget.colors != null && index < widget.colors!.length
              ? widget.colors![index]
              : defaultColors[index % defaultColors.length];

      return PieChartSectionData(
        color: color,
        value: dataEntry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: isTouched ? 55 : 50, // Reduced radius for better fit
        titleStyle: TextStyle(
          fontSize: isTouched ? 14 : 12, // Smaller font sizes
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final sortedEntries =
        widget.data.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final defaultColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];

    return Container(
      constraints: const BoxConstraints(maxHeight: 150), // Limit legend height
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children:
              sortedEntries.asMap().entries.map((entry) {
                final index = entry.key;
                final dataEntry = entry.value;

                final color =
                    widget.colors != null && index < widget.colors!.length
                        ? widget.colors![index]
                        : defaultColors[index % defaultColors.length];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dataEntry.key,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _currencyFormat.format(dataEntry.value),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}

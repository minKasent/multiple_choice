import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String chartType; // 'bar', 'pie', 'line'
  final Map<String, num> data;

  const ChartCard({
    super.key,
    required this.title,
    required this.chartType,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Simplified chart representation
            if (chartType == 'bar')
              _buildBarChart()
            else if (chartType == 'pie')
              _buildPieChart()
            else
              _buildLineChart(),
            
            const SizedBox(height: 12),
            
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: data.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getColor(data.keys.toList().indexOf(entry.key)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key}: ${entry.value}',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final maxValue = data.values.reduce((a, b) => a > b ? a : b);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: data.entries.map((entry) {
        final height = (entry.value / maxValue * 150).toDouble();
        final color = _getColor(data.keys.toList().indexOf(entry.key));
        
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              entry.value.toString(),
              style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: height,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              entry.key,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    final total = data.values.reduce((a, b) => a + b);
    
    return Row(
      children: [
        // Pie (simplified as vertical bars)
        Expanded(
          child: Column(
            children: data.entries.map((entry) {
              final percentage = (entry.value / total * 100).toDouble();
              final color = _getColor(data.keys.toList().indexOf(entry.key));
              
              return Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: percentage / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Text(
        'Line chart placeholder',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }

  Color _getColor(int index) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.warning,
      AppColors.error,
      AppColors.info,
    ];
    return colors[index % colors.length];
  }
}


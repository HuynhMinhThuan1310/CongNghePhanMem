import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final Color lineColor;
  final double barWidth;
  final Duration? tooltipDuration;

  const LineChartWidget({
    super.key,
    required this.spots,
    this.minY = 0,
    required this.maxY,
    required this.lineColor,
    this.barWidth = 2,
    this.tooltipDuration,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        // ---- TOUCH TOOLTIP ----
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipBorder: BorderSide(
              color: Colors.blue.withValues(alpha: 0.2), // FIX deprecated
              width: 1,
            ),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(1),         // FIX interpolation warning
                  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),

        // ---- GRID LINES ----
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: (maxY - minY) / 5,
          verticalInterval: (spots.isEmpty ? 10 : spots.last.x) / 10,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.3), // FIX deprecated
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: Colors.grey.withValues(alpha: 0.3), // FIX deprecated
            strokeWidth: 1,
          ),
        ),

        // ---- AXIS TITLES ----
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxY - minY) / 5,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),

        borderData: FlBorderData(show: true),

        minX: spots.isNotEmpty ? spots.first.x : 0,
        maxX: spots.isNotEmpty ? spots.last.x : 10,
        minY: minY,
        maxY: maxY,

        // ---- LINE DATA ----
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: barWidth,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.2), // FIX deprecated
            ),
          ),
        ],
      ),
    );
  }
}

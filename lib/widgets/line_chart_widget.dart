import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  final List<double> values;
  final List<DateTime>? times;

  final double minY;
  final double maxY;
  final Color color;
  final String unit;

  const LineChartWidget({
    super.key,
    required this.values,
    required this.minY,
    required this.maxY,
    required this.color,
    this.unit = "",
    this.times,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        minX: 0,
        maxX: values.isEmpty ? 0 : (values.length - 1).toDouble(),

        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),

        titlesData: FlTitlesData(
          // ================= TRỤC X (THỜI GIAN) =================
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 36, // ÉP CHỖ CHO THỜI GIAN
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (times == null || index < 0 || index >= times!.length) {
                  return const SizedBox.shrink();
                }

                final t = times![index];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${t.hour.toString().padLeft(2, '0')}:'
                    '${t.minute.toString().padLeft(2, '0')}:'
                    '${t.second.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),

          // ================= TRỤC Y (ÉP HIỆN ĐƠN VỊ) =================
          leftTitles: AxisTitles(
            axisNameWidget: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                unit, // °C, %, ppm, µg/m³
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            axisNameSize: 20, // 👈 ÉP KHÔNG GIAN CHO ĐƠN VỊ
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44, // 👈 ÉP RỘNG ĐỦ CHO SỐ
              interval: (maxY - minY) / 4,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),

          rightTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),

        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              values.length,
              (i) => FlSpot(i.toDouble(), values[i]),
            ),
            isCurved: false,
            color: color,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

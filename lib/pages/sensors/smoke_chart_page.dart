import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class SmokeChartPage extends StatefulWidget {
  const SmokeChartPage({super.key});

  @override
  State<SmokeChartPage> createState() => _SmokeChartPageState();
}

class _SmokeChartPageState extends State<SmokeChartPage> {
  final ref = FirebaseDatabase.instance.ref("ESP32C3/mq135_raw");
  final List<FlSpot> data = [];
  double time = 0;
  double currentValue = 0;

  String getSmokeLevel(double value) {
    if (value < 500) return 'An toàn';
    if (value < 1000) return 'Nhẹ';
    if (value < 2000) return 'Trung bình';
    return 'Nguy hiểm';
  }

  Color getSmokeLevelColor(double value) {
    if (value < 500) return Colors.green;
    if (value < 1000) return Colors.yellow;
    if (value < 2000) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    ref.onValue.listen((event) {
      final val = event.snapshot.value;
      if (val == null) return;
      setState(() {
        time += 1;
        currentValue = double.tryParse(val.toString()) ?? 0;
        data.add(FlSpot(time, currentValue));
        if (data.length > 30) data.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final smokeLevel = getSmokeLevel(currentValue);
    final smokeLevelColor = getSmokeLevelColor(currentValue);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Current smoke level card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smoke_free,
                        color: smokeLevelColor,
                        size: 48,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mức độ khói',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                smokeLevel,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: smokeLevelColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(${currentValue.toStringAsFixed(0)})',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Chart - Compact
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 500,
                      verticalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: Colors.grey.withOpacity(0.3),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 500,
                          reservedSize: 45,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: data.isEmpty ? 0 : data.first.x,
                    maxX: data.isEmpty ? 10 : data.last.x,
                    minY: 0,
                    maxY: 2000,
                    lineBarsData: [
                      LineChartBarData(
                        spots: data,
                        isCurved: true,
                        color: smokeLevelColor,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: smokeLevelColor.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Giá trị hiện tại', '${currentValue.toStringAsFixed(0)}', smokeLevelColor),
                  const Divider(height: 16),
                  _buildInfoRow('Mức độ', smokeLevel, smokeLevelColor),
                  const Divider(height: 16),
                  _buildInfoRow('Phạm vi an toàn', '< 500', Colors.green),
                  const Divider(height: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

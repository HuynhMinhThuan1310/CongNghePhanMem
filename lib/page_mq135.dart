import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class MQ135ChartPage extends StatefulWidget {
  const MQ135ChartPage({super.key});

  @override
  State<MQ135ChartPage> createState() => _MQ135ChartPageState();
}

class _MQ135ChartPageState extends State<MQ135ChartPage> {
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

    return Column(
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
        
        // Chart
        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 500,
                    verticalInterval: 5,
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
                      axisNameWidget: const Text('Thời gian (s)'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('Giá trị MQ135'),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 500,
                        reservedSize: 50,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: smokeLevelColor,
                      barWidth: 3,
                      belowBarData: BarAreaData(
                        show: true,
                        color: smokeLevelColor.withOpacity(0.2),
                      ),
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

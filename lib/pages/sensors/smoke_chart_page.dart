import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import '/widgets/line_chart_widget.dart';

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
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 400,
                child: LineChartWidget(
                  spots: data,
                  maxY: 2000,
                  lineColor: smokeLevelColor,
                  barWidth: 2,
                ),
              ),
            ),
          ),
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
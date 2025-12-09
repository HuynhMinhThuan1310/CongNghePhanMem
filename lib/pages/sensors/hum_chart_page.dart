import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import '/widgets/line_chart_widget.dart';

class HumChartPage extends StatefulWidget {
  const HumChartPage({super.key});

  @override
  State<HumChartPage> createState() => _HumChartPageState();
}

class _HumChartPageState extends State<HumChartPage> {
  final ref = FirebaseDatabase.instance.ref("ESP32C3/do_am");
  final List<FlSpot> data = [];
  double time = 0;
  double currentHum = 0;

  String getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Quá khô';
    if (humidity < 40) return 'Khô';
    if (humidity < 60) return 'Thoải mái';
    if (humidity < 70) return 'Hơi ẩm';
    return 'Quá ẩm';
  }

  Color getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 40) return Colors.orange;
    if (humidity < 60) return Colors.green;
    if (humidity < 70) return Colors.blue;
    return Colors.purple;
  }

  @override
  void initState() {
    super.initState();
    ref.onValue.listen((event) {
      final val = event.snapshot.value;
      if (val == null) return;
      setState(() {
        time += 1;
        currentHum = double.tryParse(val.toString()) ?? 0;
        data.add(FlSpot(time, currentHum));
        if (data.length > 30) data.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final humidityColor = getHumidityColor(currentHum);
    final humidityStatus = getHumidityStatus(currentHum);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 400,
                child: LineChartWidget(
                  spots: data,
                  maxY: 100,
                  lineColor: humidityColor,
                  barWidth: 2,
                ),
              ),
            ),
          ),
          // Info
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Thông tin chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow('Giá trị hiện tại', '${currentHum.toStringAsFixed(1)}%', humidityColor),
                  const Divider(height: 16),
                  _buildInfoRow('Trạng thái', humidityStatus, humidityColor),
                  const Divider(height: 16),
                  _buildInfoRow('Phạm vi lý tưởng', '40 - 60%', Colors.green),
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
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }
}

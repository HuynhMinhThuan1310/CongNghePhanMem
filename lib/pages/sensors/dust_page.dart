import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import '/widgets/line_chart_widget.dart';

class DustPage extends StatefulWidget {
  const DustPage({super.key});

  @override
  State<DustPage> createState() => _DustPageState();
}

class _DustPageState extends State<DustPage> {
  final refVoltage = FirebaseDatabase.instance.ref('ESP32C3/dust_voltage');
  final refDensity = FirebaseDatabase.instance.ref('ESP32C3/dust_density');

  double voltage = 0;
  double density = 0; // in ug/m3 as stored
  final List<FlSpot> _spots = [];
  double _t = 0;

  String _densityLabel(double d) {
    if (d < 50) return 'Tốt';
    if (d < 100) return 'Trung bình';
    if (d < 250) return 'Kém';
    return 'Nguy hại';
  }

  Color _densityColor(double d) {
    if (d < 50) return Colors.green;
    if (d < 100) return Colors.yellow[700]!;
    if (d < 250) return Colors.orange;
    return Colors.red;
  }

  @override
  void initState() {
    super.initState();
    refVoltage.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) return;
      setState(() {
        voltage = double.tryParse(v.toString()) ?? 0;
      });
    });
    refDensity.onValue.listen((e) {
      final d = e.snapshot.value;
      if (d == null) return;
      setState(() {
        density = double.tryParse(d.toString()) ?? 0;
        _t += 1;
        _spots.add(FlSpot(_t, density));
        if (_spots.length > 30) _spots.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _densityColor(density);
    final label = _densityLabel(density);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Chart Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 400,
                child: LineChartWidget(
                  spots: _spots,
                  maxY: 500,
                  lineColor: color,
                  barWidth: 3,
                ),
              ),
            ),
          ),
          
          // Info Section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin chi tiết',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Giá trị hiện tại', '${density.toStringAsFixed(0)} µg/m³', color),
                  const Divider(height: 16),
                  _buildInfoRow('Trạng thái', label, color),
                  const Divider(height: 16),
                  _buildInfoRow('Phạm vi lý tưởng', 'Dưới 50 µg/m³', Colors.green),
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

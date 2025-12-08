import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

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
  Widget build(BuildContext context) {
    final label = _densityLabel(density);
    final color = _densityColor(density);

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Cảm biến bụi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${density.toStringAsFixed(0)} µg/m³',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),

        Expanded(
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 500,
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
                        interval: 50,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withOpacity(0.2),
                      ),
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

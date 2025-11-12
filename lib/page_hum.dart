import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

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

  String _getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Quá khô';
    if (humidity < 40) return 'Khô';
    if (humidity < 60) return 'Thoải mái';
    if (humidity < 70) return 'Hơi ẩm';
    return 'Quá ẩm';
  }

  Color _getHumidityColor(double humidity) {
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
    final humidityColor = _getHumidityColor(currentHum);
    final humidityStatus = _getHumidityStatus(currentHum);

    return Column(
      children: [
        // Current humidity card
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
                      Icons.water_drop,
                      color: humidityColor,
                      size: 48,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Độ ẩm hiện tại',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${currentHum.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: humidityColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              humidityStatus,
                              style: TextStyle(
                                fontSize: 16,
                                color: humidityColor,
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
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipBorder: BorderSide(
                        color: Colors.blue.withOpacity(0.2),
                        width: 1,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(1)}%',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 10,
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
                      axisNameWidget: const Text(
                        'Thời gian (s)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text(
                        'Độ ẩm (%)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 10,
                        reservedSize: 42,
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
                  borderData: FlBorderData(show: true),
                  minX: data.isEmpty ? 0 : data.first.x,
                  maxX: data.isEmpty ? 10 : data.last.x,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.blue,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
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

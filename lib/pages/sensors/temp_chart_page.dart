import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '/services/firebase_database_service.dart'; 

class TempChartPage extends StatefulWidget {
  const TempChartPage({super.key});

  @override
  State<TempChartPage> createState() => _TempChartPageState();
}

class _TempChartPageState extends State<TempChartPage> {
  final FirebaseDatabaseService _db = FirebaseDatabaseService();
  StreamSubscription<double>? _tempSub;
  double currentTemp = 0;

  String _getTempStatus(double temp) {
     if (temp < 20) return 'Lạnh';
     if (temp < 25) return 'Mát mẻ';
     if (temp < 30) return 'Ấm áp';
     return 'Nóng';
    
  }

  Color _getTempColor(double temp) {
    if (temp < 20) return Colors.blue;
     if (temp < 25) return Colors.green;
     if (temp < 30) return Colors.orange;
     return Colors.red;
    
  }

  @override
  void initState() {
    super.initState();
    _tempSub = _db.getTemperatureStream().listen((temp) {
      if (!mounted) return; 
      setState(() {
        currentTemp = temp;
      });
    });
  }

  @override
  void dispose() {
    _tempSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _getTempStatus(currentTemp);
    final color = _getTempColor(currentTemp);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 50,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 20, color: Colors.blue),
                GaugeRange(startValue: 20, endValue: 25, color: Colors.green),
                GaugeRange(startValue: 25, endValue: 30, color: Colors.orange),
                GaugeRange(startValue: 30, endValue: 50, color: Colors.red),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: currentTemp,
                  needleColor: color,
                  knobStyle: const KnobStyle(color: Colors.white),
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currentTemp.toStringAsFixed(1)}°C',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

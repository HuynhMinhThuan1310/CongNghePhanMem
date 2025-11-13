import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TempChartPage extends StatefulWidget {
  const TempChartPage({super.key});

  @override
  State<TempChartPage> createState() => _TempChartPageState();
}

class _TempChartPageState extends State<TempChartPage> {
  final ref = FirebaseDatabase.instance.ref("ESP32C3/nhiet_do");
  double currentTemp = 0;

  @override
  void initState() {
    super.initState();
    ref.onValue.listen((event) {
      final val = event.snapshot.value;
      if (val == null) return;
      setState(() {
        currentTemp = double.tryParse(val.toString()) ?? 0;
      });
    });
  }

  Color _getTempColor(double temp) {
    if (temp < 20) return Colors.blue;
    if (temp < 25) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }

  String _getTempStatus(double temp) {
    if (temp < 20) return 'Lạnh';
    if (temp < 25) return 'Mát mẻ';
    if (temp < 30) return 'Ấm áp';
    return 'Nóng';
  }

  @override
  Widget build(BuildContext context) {
    final tempColor = _getTempColor(currentTemp);
    final tempStatus = _getTempStatus(currentTemp);

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SfRadialGauge(
              title: const GaugeTitle(
                text: 'Nhiệt độ',
                textStyle: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 50,
                  labelFormat: '{value}°C',
                  ranges: <GaugeRange>[
                    GaugeRange(
                      startValue: 0,
                      endValue: 20,
                      color: Colors.blue,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                    GaugeRange(
                      startValue: 20,
                      endValue: 25,
                      color: Colors.green,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                    GaugeRange(
                      startValue: 25,
                      endValue: 30,
                      color: Colors.orange,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                    GaugeRange(
                      startValue: 30,
                      endValue: 50,
                      color: Colors.red,
                      startWidth: 10,
                      endWidth: 10,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: currentTemp,
                      needleColor: tempColor,
                      needleStartWidth: 1,
                      needleEndWidth: 3,
                      knobStyle: KnobStyle(
                        knobRadius: 0.06,
                        color: tempColor,
                      ),
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
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: tempColor,
                            ),
                          ),
                          Text(
                            tempStatus,
                            style: TextStyle(
                              fontSize: 16,
                              color: tempColor,
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
        ),
      ],
    );
  }
}

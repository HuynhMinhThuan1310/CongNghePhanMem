import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GaugeWidget extends StatelessWidget {
  final double value;
  final double minimum;
  final double maximum;
  final String unit;
  final String title;
  final String status;
  final Color statusColor;
  final List<GaugeRange> ranges;

  const GaugeWidget({
    super.key,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.unit,
    required this.title,
    required this.status,
    required this.statusColor,
    required this.ranges,
  });

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      title: GaugeTitle(
        text: title,
        textStyle: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      axes: <RadialAxis>[
        RadialAxis(
          minimum: minimum,
          maximum: maximum,
          labelFormat: '{value}$unit',
          ranges: ranges,
          pointers: <GaugePointer>[
            NeedlePointer(
              value: value,
              needleColor: statusColor,
              needleStartWidth: 1,
              needleEndWidth: 3,
              knobStyle: KnobStyle(
                knobRadius: 0.06,
                color: statusColor,
              ),
            ),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$value$unit',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      color: statusColor,
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
    );
  }
}

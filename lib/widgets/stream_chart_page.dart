// stream_chart_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/widgets/line_chart_widget.dart';

class StreamChartPage extends StatefulWidget {
  final Stream<double> stream;
  final double maxY;
  final String title;

  /// ví dụ: "An toàn", "Trung bình", "Nguy hiểm"
  final String Function(double) statusBuilder;

  /// ví dụ màu theo giá trị
  final Color Function(double) colorBuilder;

  /// phạm vi an toàn: "< 500", "20–30°C"
  final String safeRangeText;

  const StreamChartPage({
    super.key,
    required this.stream,
    required this.maxY,
    required this.title,
    required this.statusBuilder,
    required this.colorBuilder,
    required this.safeRangeText,
  });

  @override
  State<StreamChartPage> createState() => _StreamChartPageState();
}

class _StreamChartPageState extends State<StreamChartPage> {
  final List<FlSpot> _data = [];
  double _time = 0;
  double _current = 0;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((value) {
      if (!mounted) return;
      setState(() {
        _time += 1;
        _current = value;
        _data.add(FlSpot(_time, _current));
        if (_data.length > 30) _data.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.statusBuilder(_current);
    final color = widget.colorBuilder(_current);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ───────────── CHART ─────────────
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 200,
                child: LineChartWidget(
                  spots: _data,
                  maxY: widget.maxY,
                  lineColor: color,
                ),
              ),
            ),
          ),

          // ───────────── INFO BOX ─────────────
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    "Thông tin chi tiết",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow("Giá trị hiện tại", _current.toStringAsFixed(1), color),
                  const Divider(height: 16),
                  _buildInfoRow("Mức độ", status, color),
                  const Divider(height: 16),
                  _buildInfoRow("Phạm vi an toàn", widget.safeRangeText, Colors.green),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
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

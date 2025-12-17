import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/line_chart_widget.dart';

class StreamChartPage extends StatefulWidget {
  final Stream<double> stream;
  final double minY;
  final double maxY;
  final String title;
  final String unit;

  final String Function(double) statusBuilder;
  final Color Function(double) colorBuilder;

  final String safeRangeText;
  final int historyPoints;
  final Duration staleAfter;

  final String Function(double)? valueFormatter;
  final List<String> tips;

  const StreamChartPage({
    super.key,
    required this.stream,
    this.minY = 0,
    required this.maxY,
    required this.title,
    this.unit = "",
    required this.statusBuilder,
    required this.colorBuilder,
    required this.safeRangeText,
    this.historyPoints = 40,
    this.staleAfter = const Duration(seconds: 10),
    this.valueFormatter,
    this.tips = const [],
  });

  @override
  State<StreamChartPage> createState() => _StreamChartPageState();
}

class _StreamChartPageState extends State<StreamChartPage> {
  final List<double> _history = [];
  final List<DateTime> _times = [];

  double? _currentValue;
  DateTime? _lastUpdate;
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();

    _sub = widget.stream.listen((value) {
      setState(() {
        _currentValue = value;
        _lastUpdate = DateTime.now();

        _history.add(value);
        _times.add(_lastUpdate!);

        if (_history.length > widget.historyPoints) {
          _history.removeAt(0);
          _times.removeAt(0);
        }
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _isStale {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > widget.staleAfter;
  }

  @override
  Widget build(BuildContext context) {
    final statusText =
        _currentValue != null ? widget.statusBuilder(_currentValue!) : "--";

    final valueText = _currentValue != null
        ? (widget.valueFormatter?.call(_currentValue!) ??
            _currentValue!.toStringAsFixed(1))
        : "--";

    final color =
        _currentValue != null ? widget.colorBuilder(_currentValue!) : Colors.grey;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== GIÁ TRỊ HIỆN TẠI =====
            Row(
              children: [
                Text(
                  "$valueText ${widget.unit}",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Chip(
                  label: Text(statusText),
                  backgroundColor: color.withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: color),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text("Ngưỡng an toàn: ${widget.safeRangeText}"),

            const SizedBox(height: 16),

            // ===== BIỂU ĐỒ =====
            Expanded(
              child: LineChartWidget(
                values: _history,
                times: _times,
                minY: widget.minY,
                maxY: widget.maxY,
                color: color,
                unit: widget.unit,
              ),
            ),

            // ===== CẢNH BÁO MẤT KẾT NỐI =====
            if (_isStale)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "⚠ Dữ liệu chưa được cập nhật",
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            // ===== TIP =====
            if (widget.tips.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Khuyến nghị:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...widget.tips.map(
                (e) => Text("• $e"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/line_chart_widget.dart';

class StreamChartPage extends StatefulWidget {
  final Stream<double> stream;

  /// ✅ Stream heartbeat (ESP32C3/last_seen) để biết còn online dù value đứng
  final Stream<dynamic>? heartbeatStream;

  /// ✅ Nhịp “chạy trục thời gian” (mỗi tick thêm 1 điểm)
  final Duration sampleInterval;

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
    this.heartbeatStream,
    this.sampleInterval = const Duration(seconds: 1),
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
  StreamSubscription? _hbSub;
  Timer? _timer;

  bool get _isStale {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > widget.staleAfter;
  }

  void _appendPoint(double value, DateTime time) {
    _history.add(value);
    _times.add(time);

    if (_history.length > widget.historyPoints) {
      final extra = _history.length - widget.historyPoints;
      _history.removeRange(0, extra);
      _times.removeRange(0, extra);
    }
  }

  @override
  void initState() {
    super.initState();

    // 1) Nhận giá trị cảm biến (có thể ít event nếu value không đổi)
    _sub = widget.stream.listen((value) {
      setState(() {
        _currentValue = value;
        // coi như có update
        _lastUpdate = DateTime.now();
      });
    });

    // 2) Heartbeat: cập nhật lastUpdate đều để không báo stale sai
    _hbSub = widget.heartbeatStream?.listen((_) {
      if (!mounted) return;
      setState(() {
        _lastUpdate = DateTime.now();
      });
    });

    // 3) Timer: để trục thời gian “chạy” => mỗi sampleInterval thêm 1 điểm
    _timer = Timer.periodic(widget.sampleInterval, (_) {
      if (!mounted) return;

      // Chỉ chạy khi còn online (không stale) và đã có giá trị đầu tiên
      if (_isStale) return;
      if (_currentValue == null) return;

      setState(() {
        _appendPoint(_currentValue!, DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hbSub?.cancel();
    _timer?.cancel();
    super.dispose();
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

            if (_isStale)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "⚠ Dữ liệu chưa được cập nhật",
                  style: TextStyle(color: Colors.orange),
                ),
              ),

            if (widget.tips.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                "Khuyến nghị:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...widget.tips.map((e) => Text("• $e")),
            ],
          ],
        ),
      ),
    );
  }
}

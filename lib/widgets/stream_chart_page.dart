import 'dart:async';
import 'package:flutter/material.dart';

import '../widgets/line_chart_widget.dart';

class StreamChartPage extends StatefulWidget {
  final Stream<double> stream;

  final Stream<dynamic>? heartbeatStream;
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

  // dùng để trigger rebuild khi trạng thái stale thay đổi
  bool _staleShown = true;

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

  void _markUpdated() {
    _lastUpdate = DateTime.now();
    _staleShown = false;
  }

  @override
  void initState() {
    super.initState();

    // 1) nghe stream dữ liệu chính
    _sub = widget.stream.listen((value) {
      if (!mounted) return;
      setState(() {
        _currentValue = value;
        _markUpdated();
      });
    });

    // 2) nghe heartbeat (tuỳ chọn)
    _hbSub = widget.heartbeatStream?.listen((_) {
      if (!mounted) return;
      setState(() {
        _markUpdated();
      });
    });

    // 3) timer: vừa lấy mẫu cho chart, vừa cập nhật stale UI
    _timer = Timer.periodic(widget.sampleInterval, (_) {
      if (!mounted) return;

      final nowStale = _isStale;

      // stale chuyển trạng thái thì rebuild để hiện/ẩn cảnh báo
      if (nowStale != _staleShown) {
        setState(() {
          _staleShown = nowStale;
        });
      }

      // nếu stale hoặc chưa có data -> không thêm điểm
      if (nowStale) return;
      if (_currentValue == null) return;

      // thêm điểm vào chart
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

    final staleNow = _isStale;

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
                  backgroundColor: color.withValues(alpha: 0.14),
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
            if (staleNow)
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

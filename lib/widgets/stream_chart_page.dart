import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '/widgets/line_chart_widget.dart';

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
  final List<FlSpot> _data = [];
  double _time = 0;
  double _current = 0;

  DateTime? _lastUpdate;
  bool _stale = false;

  StreamSubscription<double>? _sub;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _sub = widget.stream.listen((value) {
      if (!mounted) return;
      setState(() {
        _time += 1;
        _current = value;
        _lastUpdate = DateTime.now();
        _stale = false;

        _data.add(FlSpot(_time, _current));
        if (_data.length > widget.historyPoints) _data.removeAt(0);
      });
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final t = _lastUpdate;
      if (t == null) return;
      final now = DateTime.now();
      final isStaleNow = now.difference(t) > widget.staleAfter;
      if (isStaleNow != _stale) {
        setState(() => _stale = isStaleNow);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  String _fmtValue(double v) {
    final f = widget.valueFormatter;
    if (f != null) return f(v);
    return v.toStringAsFixed(1);
  }

  String _fmtClock(DateTime? t) {
    if (t == null) return "—";
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final ss = t.second.toString().padLeft(2, '0');
    return "$hh:$mm:$ss";
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final status = widget.statusBuilder(_current);
    final color = widget.colorBuilder(_current);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== LIVE HEADER =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.sensors_rounded, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _pill(
                              text: _stale ? "MẤT TÍN HIỆU" : "LIVE",
                              bg: _stale ? cs.errorContainer : cs.primaryContainer,
                              fg: _stale ? cs.onErrorContainer : cs.onPrimaryContainer,
                              dot: !_stale,
                            ),
                            _pill(
                              text: "Cập nhật: ${_fmtClock(_lastUpdate)}",
                              bg: cs.surfaceContainerHighest,
                              fg: cs.onSurface,
                            ),
                            _pill(
                              text: status,
                              bg: color.withValues(alpha: 0.14),
                              fg: color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${_fmtValue(_current)}${widget.unit}",
                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: color),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== CHART =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 260,
                child: LineChartWidget(
                  spots: _data,
                  minY: widget.minY,
                  maxY: widget.maxY,
                  lineColor: color,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ===== INFO =====
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Thông tin", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  _row("Giá trị hiện tại", "${_fmtValue(_current)}${widget.unit}", color),
                  const Divider(height: 18),
                  _row("Mức độ", status, color),
                  const Divider(height: 18),
                  _row("Phạm vi khuyến nghị", widget.safeRangeText, cs.primary),
                ],
              ),
            ),
          ),

          if (widget.tips.isNotEmpty) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gợi ý thực tế", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    ...widget.tips.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                              const SizedBox(width: 10),
                              Expanded(child: Text(t)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: valueColor),
          ),
        ),
      ],
    );
  }

  Widget _pill({
    required String text,
    required Color bg,
    required Color fg,
    bool dot = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
            const SizedBox(width: 7),
          ],
          Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

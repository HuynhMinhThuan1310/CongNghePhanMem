import 'package:flutter/material.dart';
import '../../services/firebase_database_service.dart';
import '../../widgets/line_chart_widget.dart';

class HistoryChartPage extends StatefulWidget {
  final String sensorKey;
  final String title;
  final String unit;
  final double minY;
  final double maxY;
  final Color color;

  const HistoryChartPage({
    super.key,
    required this.sensorKey,
    required this.title,
    required this.unit,
    required this.minY,
    required this.maxY,
    required this.color,
  });

  @override
  State<HistoryChartPage> createState() => _HistoryChartPageState();
}

class _HistoryChartPageState extends State<HistoryChartPage> {
  final FirebaseDatabaseService _db = FirebaseDatabaseService();

  DateTime _selectedDate = DateTime.now();
  bool _loading = true;

  List<double> _values = [];
  List<DateTime> _times = [];

  double? _max;
  double? _min;
  double? _avg;

  final Map<String, double> _avgLast3Days = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  // ===== LOAD LỊCH SỬ NGÀY ĐANG CHỌN =====
  Future<void> _loadHistory() async {
    setState(() => _loading = true);

    final data = await _db.getHistoryByDate(
      sensorKey: widget.sensorKey,
      dateKey: _dateKey(_selectedDate),
    );

    final sortedKeys = data.keys.toList()..sort();

    _values = [];
    _times = [];

    for (final k in sortedKeys) {
      _values.add(data[k]!);

      final parts = k.split(":");
      if (parts.length == 3) {
        _times.add(DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ));
      }
    }

    _calcStats();
    await _loadLast3DaysAvg();

    setState(() => _loading = false);
  }

  // ===== TÍNH MAX / MIN / AVG =====
  void _calcStats() {
    if (_values.isEmpty) {
      _max = _min = _avg = null;
      return;
    }

    _max = _values.reduce((a, b) => a > b ? a : b);
    _min = _values.reduce((a, b) => a < b ? a : b);
    _avg = _values.reduce((a, b) => a + b) / _values.length;
  }

  // ===== TRUNG BÌNH 3 NGÀY TRƯỚC =====
  Future<void> _loadLast3DaysAvg() async {
    _avgLast3Days.clear();

    for (int i = 1; i <= 3; i++) {
      final d = _selectedDate.subtract(Duration(days: i));
      final key = _dateKey(d);

      final data = await _db.getHistoryByDate(
        sensorKey: widget.sensorKey,
        dateKey: key,
      );

      if (data.isEmpty) continue;

      final values = data.values.toList();
      final avg = values.reduce((a, b) => a + b) / values.length;
      _avgLast3Days[key] = avg;
    }
  }

  // ===== CHỌN NGÀY =====
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _selectedDate = picked;
      await _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} – Lịch sử"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _values.isEmpty
                ? const Center(child: Text("Không có dữ liệu cho ngày này"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ngày: ${_dateKey(_selectedDate)}",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),

                      const SizedBox(height: 12),

                      // ===== BOX THỐNG KÊ =====
                      if (_max != null && _min != null && _avg != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatBox(
                                label: "MAX",
                                value: _max!,
                                unit: widget.unit),
                            _StatBox(
                                label: "MIN",
                                value: _min!,
                                unit: widget.unit),
                            _StatBox(
                                label: "AVG",
                                value: _avg!,
                                unit: widget.unit),
                          ],
                        ),

                      const SizedBox(height: 16),

                      // ===== BIỂU ĐỒ =====
                      Expanded(
                        child: LineChartWidget(
                          values: _values,
                          times: _times,
                          minY: widget.minY,
                          maxY: widget.maxY,
                          color: widget.color,
                          unit: widget.unit,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ===== SO SÁNH 3 NGÀY TRƯỚC =====
                      if (_avgLast3Days.isNotEmpty) ...[
                        const Text(
                          "So sánh trung bình 3 ngày trước:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        ..._avgLast3Days.entries.map(
                          (e) => Text(
                            "${e.key}: ${e.value.toStringAsFixed(1)} ${widget.unit}",
                          ),
                        ),
                      ],
                    ],
                  ),
      ),
    );
  }
}

// ===== WIDGET NHỎ HIỂN THỊ SỐ =====
class _StatBox extends StatelessWidget {
  final String label;
  final double value;
  final String unit;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          "${value.toStringAsFixed(1)} $unit",
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}

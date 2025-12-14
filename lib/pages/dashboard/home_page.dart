import 'dart:async';
import 'package:flutter/material.dart';

import '../../services/firebase_database_service.dart';
import '../../services/sensor_status.dart';

import '../sensors/temp_chart_page.dart';
import '../sensors/hum_chart_page.dart';
import '../sensors/smoke_chart_page.dart';
import '../sensors/dust_page.dart';
import '../sensors/conclusion_page.dart';

class HomePage extends StatefulWidget {
  final void Function(Widget page, String title)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _db = FirebaseDatabaseService();

  StreamSubscription<double>? _tSub, _hSub, _sSub, _dSub;

  double t = 0, h = 0, s = 0, d = 0;
  DateTime? tAt, hAt, sAt, dAt;

  // ===== tổng quan chỉ update mỗi 5s =====
  Timer? _summaryTimer;
  int _scoreDisplay = 0;
  String _healthDisplay = "—";
  DateTime? _summaryAt;

  @override
  void initState() {
    super.initState();

    // stream vẫn realtime (GIỮ NGUYÊN đường dẫn đọc Firebase trong service)
    _tSub = _db.getTemperatureStream().listen((v) => _setVal('t', v));
    _hSub = _db.getHumidityStream().listen((v) => _setVal('h', v));
    _sSub = _db.getSmokeStream().listen((v) => _setVal('s', v));
    _dSub = _db.getDustDensityStream().listen((v) => _setVal('d', v));

    // chỉ cập nhật "điểm tổng quan" mỗi 5 giây
    _summaryTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _scoreDisplay = _totalScore();
        _healthDisplay = _healthStatus();
        _summaryAt = DateTime.now();
      });
    });

    // cập nhật lần đầu sau 0.5s để có số sớm
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _scoreDisplay = _totalScore();
        _healthDisplay = _healthStatus();
        _summaryAt = DateTime.now();
      });
    });
  }

  void _setVal(String k, double v) {
    if (!mounted) return;
    setState(() {
      final now = DateTime.now();
      switch (k) {
        case 't':
          t = v;
          tAt = now;
          break;
        case 'h':
          h = v;
          hAt = now;
          break;
        case 's':
          s = v;
          sAt = now;
          break;
        case 'd':
          d = v;
          dAt = now;
          break;
      }
    });
  }

  @override
  void dispose() {
    _tSub?.cancel();
    _hSub?.cancel();
    _sSub?.cancel();
    _dSub?.cancel();
    _summaryTimer?.cancel();
    super.dispose();
  }

  // ===== score giống thực tế =====
  int _tempScore(double v) {
    if (v < 20) return 70;
    if (v < 28) return 100;
    if (v < 33) return 80;
    return 40;
  }

  int _humScore(double v) {
    if (v < 30) return 50;
    if (v < 40) return 70;
    if (v < 60) return 100;
    if (v < 70) return 80;
    return 50;
  }

  int _dustScore(double v) {
    if (v < 50) return 100;
    if (v < 100) return 70;
    if (v < 150) return 50;
    return 30;
  }

  int _smokeScore(double v) {
    if (v < 500) return 100;
    if (v < 1000) return 70;
    if (v < 2000) return 50;
    return 20;
  }

  int _totalScore() {
    return (_tempScore(t) + _humScore(h) + _dustScore(d) + _smokeScore(s)) ~/ 4;
  }

  String _healthStatus() {
    final score = _totalScore();
    if (score >= 85) return "Rất tốt";
    if (score >= 70) return "Tốt";
    if (score >= 50) return "Trung bình";
    return "Kém";
  }

  DateTime? get _lastAny {
    final list = [tAt, hAt, sAt, dAt].whereType<DateTime>().toList();
    if (list.isEmpty) return null;
    list.sort();
    return list.last;
  }

  bool get _online {
    final last = _lastAny;
    if (last == null) return false;
    return DateTime.now().difference(last) <= const Duration(seconds: 10);
  }

  String _ago(DateTime? dt) {
    if (dt == null) return "—";
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s trước";
    if (diff.inMinutes < 60) return "${diff.inMinutes}p trước";
    return "${diff.inHours}h trước";
  }

  void _go(Widget page, String title) {
    final cb = widget.onNavigate;
    if (cb != null) {
      cb(page, title);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(appBar: AppBar(title: Text(title)), body: page),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final dateText =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HERO =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [cs.primary, cs.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Môi trường trong nhà",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _online ? Colors.greenAccent : Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _online ? "ONLINE" : "OFFLINE",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(dateText, style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Điểm tổng quan (cập nhật 3s/lần)",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      "${_scoreDisplay.clamp(0, 100)}/100 • $_healthDisplay",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (_scoreDisplay.clamp(0, 100)) / 100,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                Text(
                  "Cập nhật tổng quan: ${_ago(_summaryAt)}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ===== CHỈ GIỮ 1 NÚT: Xem tổng quan (xóa Chi tiết) =====
          _bigAction(
            icon: Icons.dashboard_customize_rounded,
            title: "Xem tổng quan",
            subtitle: "Phân tích & kết luận",
            onTap: () => _go(const ConclusionPage(), "Tổng quan"),
          ),

          const SizedBox(height: 14),

          const Text(
            "Chỉ số realtime",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          // ===== 4 THẺ NGẮN LẠI =====
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 156, // ✅ cố định chiều cao cho ngắn lại
            ),
            children: [
              _metricCard(
                title: "Nhiệt độ",
                value: "${t.toStringAsFixed(1)}°C",
                status: SensorStatus.tempStatus(t),
                color: SensorStatus.tempColor(t),
                updated: _ago(tAt),
                icon: Icons.thermostat_rounded,
                onTap: () => _go(const TempChartPage(), "Nhiệt độ"),
              ),
              _metricCard(
                title: "Độ ẩm",
                value: "${h.toStringAsFixed(1)}%",
                status: SensorStatus.humStatus(h),
                color: SensorStatus.humColor(h),
                updated: _ago(hAt),
                icon: Icons.water_drop_rounded,
                onTap: () => _go(const HumChartPage(), "Độ ẩm"),
              ),
              _metricCard(
                title: "Khí (MQ135)",
                value: s.toStringAsFixed(0),
                status: SensorStatus.smokeStatus(s),
                color: SensorStatus.smokeColor(s),
                updated: _ago(sAt),
                icon: Icons.air_rounded,
                onTap: () => _go(const SmokeChartPage(), "Khí gas"),
              ),
              _metricCard(
                title: "Bụi mịn",
                value: "${d.toStringAsFixed(1)} µg/m³",
                status: SensorStatus.dustStatus(d),
                color: SensorStatus.dustColor(d),
                updated: _ago(dAt),
                icon: Icons.grain_rounded,
                onTap: () => _go(const DustPage(), "Bụi (PM)"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bigAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
  required String title,
  required String value,
  required String status,
  required Color color,
  required String updated,
  required IconData icon,
  required VoidCallback onTap,
}) {
  final cs = Theme.of(context).colorScheme;

  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(10), // giảm padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: cs.onSurface),
            ),
            const Spacer(),
            Text(
              "Cập nhật: $updated",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            ),
          ],
        ),
      ),
    ),
  );
}
}
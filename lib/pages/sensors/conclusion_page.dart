import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/firebase_database_service.dart';
import '../../services/sensor_status.dart';

class ConclusionPage extends StatefulWidget {
  const ConclusionPage({super.key});

  @override
  State<ConclusionPage> createState() => _ConclusionPageState();
}

class _ConclusionPageState extends State<ConclusionPage> {
  final FirebaseDatabaseService _db = FirebaseDatabaseService();

  double _temperature = 0;
  double _humidity = 0;
  double _dust = 0;
  double _smoke = 0;

  double _tPending = 0;
  double _hPending = 0;
  double _dPending = 0;
  double _sPending = 0;

  StreamSubscription<double>? _tempSub;
  StreamSubscription<double>? _humSub;
  StreamSubscription<double>? _dustSub;
  StreamSubscription<double>? _smokeSub;

  Timer? _tick;
  DateTime? _lastUiUpdate;

  @override
  void initState() {
    super.initState();

    _tempSub = _db.getTemperatureStream().listen((v) => _tPending = v);
    _humSub = _db.getHumidityStream().listen((v) => _hPending = v);
    _dustSub = _db.getDustDensityStream().listen((v) => _dPending = v);
    _smokeSub = _db.getSmokeStream().listen((v) => _sPending = v);

    _tick = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _temperature = _tPending;
        _humidity = _hPending;
        _dust = _dPending;
        _smoke = _sPending;
        _lastUiUpdate = DateTime.now();
      });
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _temperature = _tPending;
        _humidity = _hPending;
        _dust = _dPending;
        _smoke = _sPending;
        _lastUiUpdate = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _tempSub?.cancel();
    _humSub?.cancel();
    _dustSub?.cancel();
    _smokeSub?.cancel();
    _tick?.cancel();
    super.dispose();
  }

  int _tempScore(double t) {
    if (t < 20) return 70;
    if (t < 28) return 100;
    if (t < 33) return 80;
    return 40;
  }

  int _humScore(double h) {
    if (h < 30) return 50;
    if (h < 40) return 70;
    if (h < 60) return 100;
    if (h < 70) return 80;
    return 50;
  }

  int _dustScore(double d) {
    if (d < 50) return 100;
    if (d < 100) return 70;
    if (d < 150) return 50;
    return 30;
  }

  int _smokeScore(double v) {
    if (v < 600) return 100;
    if (v < 1000) return 70;
    if (v < 2000) return 50;
    return 20;
  }

  int _totalScore() {
    return (_tempScore(_temperature) +
            _humScore(_humidity) +
            _dustScore(_dust) +
            _smokeScore(_smoke)) ~/
        4;
  }

  String _healthStatus() {
    final score = _totalScore();
    if (score >= 85) return "Môi trường rất tốt";
    if (score >= 70) return "Môi trường tốt";
    if (score >= 50) return "Môi trường trung bình";
    return "Môi trường xấu";
  }

  Color _healthColor() {
    final score = _totalScore();
    if (score >= 85) return Colors.green;
    if (score >= 70) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _fmtClock(DateTime? t) {
    if (t == null) return "—";
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final ss = t.second.toString().padLeft(2, '0');
    return "$hh:$mm:$ss";
  }

  Widget _buildTile({
    required String title,
    required String value,
    required String status,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 6),
                  Text(value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: color,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    status,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overallColor = _healthColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tổng quan môi trường
          Card(
            color: overallColor.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Đánh giá tổng quan môi trường",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _healthStatus(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: overallColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Điểm đánh giá: ${_totalScore()}/100",
                    style: TextStyle(fontSize: 14, color: overallColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Cập nhật (3s/lần): ${_fmtClock(_lastUiUpdate)}",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Nhiệt độ
          _buildTile(
            title: "Nhiệt độ",
            value: "${_temperature.toStringAsFixed(1)}°C",
            status: SensorStatus.tempStatus(_temperature),
            color: SensorStatus.tempColor(_temperature),
            icon: Icons.thermostat,
          ),

          // Độ ẩm
          _buildTile(
            title: "Độ ẩm",
            value: "${_humidity.toStringAsFixed(1)}%",
            status: SensorStatus.humStatus(_humidity),
            color: SensorStatus.humColor(_humidity),
            icon: Icons.water_drop,
          ),

          // Bụi PM
          _buildTile(
            title: "Bụi PM",
            value: "${_dust.toStringAsFixed(1)} µg/m³",
            status: SensorStatus.dustStatus(_dust),
            color: SensorStatus.dustColor(_dust),
            icon: Icons.grain,
          ),

          // Khí độc
          _buildTile(
            title: "Khí độc MQ135",
            value: "${_smoke.toStringAsFixed(0)} ppm",
            status: SensorStatus.smokeStatus(_smoke),
            color: SensorStatus.smokeColor(_smoke),
            icon: Icons.smoke_free,
          ),
        ],
      ),
    );
  }
}
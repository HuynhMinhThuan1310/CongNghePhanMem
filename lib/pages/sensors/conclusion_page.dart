import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ConclusionPage extends StatefulWidget {
  const ConclusionPage({super.key});

  @override
  State<ConclusionPage> createState() => _ConclusionPageState();
}

class _ConclusionPageState extends State<ConclusionPage> {
  final refTemp = FirebaseDatabase.instance.ref("ESP32C3/nhiet_do");
  final refHum = FirebaseDatabase.instance.ref("ESP32C3/do_am");
  final refDust = FirebaseDatabase.instance.ref("ESP32C3/dust_density");
  final refSmoke = FirebaseDatabase.instance.ref("ESP32C3/mq135_raw");

  double temperature = 0, humidity = 0, dust = 0, smoke = 0;
  late Timer _timer;
  Color statusColor = Colors.grey;
  String overallStatus = "Đang phân tích...";
  String details = "";

  @override
  void initState() {
    super.initState();
    _listen();
    _startTimer();
  }

  void _listen() {
    refTemp.onValue.listen((e) => temperature = _parse(e.snapshot.value));
    refHum.onValue.listen((e) => humidity = _parse(e.snapshot.value));
    refDust.onValue.listen((e) => dust = _parse(e.snapshot.value));
    refSmoke.onValue.listen((e) => smoke = _parse(e.snapshot.value));
  }

  double _parse(dynamic v) => double.tryParse(v.toString()) ?? 0;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _update());
    _update();
  }

  void _update() {
    final tempS = _tempStatus(temperature);
    final humS = _humStatus(humidity);
    final dustS = _dustStatus(dust);
    final smokeS = _smokeStatus(smoke);

    final score = (_tempScore(temperature) + _humScore(humidity) + _dustScore(dust) + _smokeScore(smoke)) / 4;

    if (score >= 2.8) {
      overallStatus = "MÔI TRƯỜNG TỐT";
      statusColor = Colors.green;
    } else if (score >= 2) {
      overallStatus = "MÔI TRƯỜNG TRUNG BÌNH";
      statusColor = Colors.orange;
    } else {
      overallStatus = "MÔI TRƯỜNG KÉM";
      statusColor = Colors.red;
    }

    details = """
🌡️ Nhiệt độ: $tempS (${temperature.toStringAsFixed(1)}°C)
💧 Độ ẩm: $humS (${humidity.toStringAsFixed(1)}%)
🌫️ Bụi: $dustS (${dust.toStringAsFixed(0)} µg/m³)
🔥 Khí độc: $smokeS (${smoke.toStringAsFixed(0)})
""";

    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // === STATUS FUNCTIONS ===

  String _tempStatus(double t) =>
      t < 20 ? "Lạnh" : t < 25 ? "Mát" : t < 30 ? "Ấm áp" : "Nóng";
  double _tempScore(double t) =>
      (t < 20 || t > 30) ? 1 : (t < 25) ? 3 : (t < 28) ? 2 : 1;

  String _humStatus(double h) =>
      h < 30 ? "Quá khô" : h < 40 ? "Khô" : h < 60 ? "Thoải mái" : h < 70 ? "Hơi ẩm" : "Quá ẩm";
  double _humScore(double h) =>
      (h < 30 || h > 70) ? 1 : (h < 40 || h > 60) ? 2 : 3;

  String _dustStatus(double d) =>
      d < 50 ? "Tốt" : d < 100 ? "Trung bình" : d < 250 ? "Kém" : "Nguy hại";
  double _dustScore(double d) =>
      d < 50 ? 3 : d < 100 ? 2 : d < 250 ? 1.5 : 1;

  String _smokeStatus(double v) =>
      v < 500 ? "An toàn" : v < 1000 ? "Nhẹ" : v < 2000 ? "TB" : "Nguy hiểm";
  double _smokeScore(double v) =>
      v < 500 ? 3 : v < 1000 ? 2 : v < 2000 ? 1.5 : 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ==== HEADER ====
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.circle, color: statusColor, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      overallStatus,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ==== DETAILS ====
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  details,
                  style: const TextStyle(fontSize: 16, height: 1.8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

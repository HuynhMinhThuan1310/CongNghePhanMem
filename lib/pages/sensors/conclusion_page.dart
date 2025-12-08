import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

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

  double temperature = 0;
  double humidity = 0;
  double dustDensity = 0;
  double smokeValue = 0;

  late Timer _conclusionTimer;
  String conclusion = "Đang tải dữ liệu...";
  Color conclusionColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _initializeListeners();
    _startConclusionTimer();
  }

  void _initializeListeners() {
    refTemp.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) return;
      setState(() {
        temperature = double.tryParse(v.toString()) ?? 0;
      });
    });

    refHum.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) return;
      setState(() {
        humidity = double.tryParse(v.toString()) ?? 0;
      });
    });

    refDust.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) return;
      setState(() {
        dustDensity = double.tryParse(v.toString()) ?? 0;
      });
    });

    refSmoke.onValue.listen((e) {
      final v = e.snapshot.value;
      if (v == null) return;
      setState(() {
        smokeValue = double.tryParse(v.toString()) ?? 0;
      });
    });
  }

  void _startConclusionTimer() {
    _conclusionTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _updateConclusion();
    });
    // Cập nhật lần đầu ngay lập tức
    _updateConclusion();
  }

  void _updateConclusion() {
    setState(() {
      final tempStatus = _getTempStatus(temperature);
      final humStatus = _getHumidityStatus(humidity);
      final dustStatus = _getDustStatus(dustDensity);
      final smokeStatus = _getSmokeStatus(smokeValue);

      final tempScore = _getTempScore(temperature);
      final humScore = _getHumidityScore(humidity);
      final dustScore = _getDustScore(dustDensity);
      final smokeScore = _getSmokeScore(smokeValue);

      final totalScore = (tempScore + humScore + dustScore + smokeScore) / 4;

      // Xây dựng kết luận
      List<String> conclusions = [];

      conclusions.add("🌡️ Nhiệt độ: $tempStatus (${temperature.toStringAsFixed(1)}°C)");
      conclusions.add("💧 Độ ẩm: $humStatus (${humidity.toStringAsFixed(1)}%)");
      conclusions.add("🌫️ Bụi: $dustStatus (${dustDensity.toStringAsFixed(0)} µg/m³)");
      conclusions.add("🔥 Khí độc: $smokeStatus (${smokeValue.toStringAsFixed(0)})");

      conclusion = conclusions.join("\n");

      // Xác định màu tổng thể dựa trên điểm tổng hợp
      if (totalScore >= 3) {
        conclusionColor = Colors.green;
      } else if (totalScore >= 2) {
        conclusionColor = Colors.orange;
      } else {
        conclusionColor = Colors.red;
      }
    });
  }

  String _getTempStatus(double temp) {
    if (temp < 20) return 'Lạnh';
    if (temp < 25) return 'Mát mẻ';
    if (temp < 30) return 'Ấm áp';
    return 'Nóng';
  }

  double _getTempScore(double temp) {
    if (temp < 20 || temp > 30) return 1;
    if (temp < 25 || temp > 28) return 2;
    return 3;
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < 30) return 'Quá khô';
    if (humidity < 40) return 'Khô';
    if (humidity < 60) return 'Thoải mái';
    if (humidity < 70) return 'Hơi ẩm';
    return 'Quá ẩm';
  }

  double _getHumidityScore(double humidity) {
    if (humidity < 30 || humidity > 70) return 1;
    if (humidity < 40 || humidity > 60) return 2;
    return 3;
  }

  String _getDustStatus(double dust) {
    if (dust < 50) return 'Tốt';
    if (dust < 100) return 'Trung bình';
    if (dust < 250) return 'Kém';
    return 'Nguy hại';
  }

  double _getDustScore(double dust) {
    if (dust < 50) return 3;
    if (dust < 100) return 2;
    if (dust < 250) return 1.5;
    return 1;
  }

  String _getSmokeStatus(double value) {
    if (value < 500) return 'An toàn';
    if (value < 1000) return 'Nhẹ';
    if (value < 2000) return 'Trung bình';
    return 'Nguy hiểm';
  }

  double _getSmokeScore(double value) {
    if (value < 500) return 3;
    if (value < 1000) return 2;
    if (value < 2000) return 1.5;
    return 1;
  }

  String _getOverallStatus() {
    final tempScore = _getTempScore(temperature);
    final humScore = _getHumidityScore(humidity);
    final dustScore = _getDustScore(dustDensity);
    final smokeScore = _getSmokeScore(smokeValue);
    final totalScore = (tempScore + humScore + dustScore + smokeScore) / 4;

    if (totalScore >= 2.8) {
      return '✅ MÔI TRƯỜNG TỐT';
    } else if (totalScore >= 2) {
      return '⚠️ MÔI TRƯỜNG BÌNH THƯỜNG';
    } else {
      return '❌ MÔI TRƯỜNG KÉM';
    }
  }

  @override
  void dispose() {
    _conclusionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [conclusionColor.withAlpha(200), conclusionColor.withAlpha(100)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TỔNG KẾT',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _getOverallStatus(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Conclusion Details
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chi tiết các nguồn dữ liệu:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      conclusion,
                      style: TextStyle(
                        fontSize: 16,
                        height: 2,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDataTable(),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Kết luận được cập nhật mỗi 30 giây dựa trên dữ liệu từ 4 cảm biến',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey[300]!),
      columnWidths: {
        0: const FlexColumnWidth(2),
        1: const FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey[100],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Thông số',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Giá trị',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Nhiệt độ'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${temperature.toStringAsFixed(1)}°C'),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Độ ẩm'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${humidity.toStringAsFixed(1)}%'),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Bụi'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${dustDensity.toStringAsFixed(0)} µg/m³'),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('Khí độc (MQ135)'),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('${smokeValue.toStringAsFixed(0)}'),
            ),
          ],
        ),
      ],
    );
  }
}

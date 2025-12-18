import 'package:flutter/material.dart';

import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';
import 'history_chart_page.dart';

class SmokeChartPage extends StatelessWidget {
  const SmokeChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Khí gas / Không khí (MQ135)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Xem lịch sử",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryChartPage(
                    sensorKey: "mq135",
                    title: "Khí gas / Không khí",
                    unit: "",
                    minY: 0,
                    maxY: 4500,
                    color: Colors.deepOrange,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamChartPage(
        stream: db.getSmokeStream(),
        heartbeatStream: db.getLastSeenStream(), // ✅ chart vẫn chạy dù số liệu đứng
        sampleInterval: const Duration(seconds: 3),
        maxY: 4500,
        title: "", // ❗ tắt title trong chart
        historyPoints: 10,
        unit: "",
        valueFormatter: (v) => v.toStringAsFixed(0),
        statusBuilder: SensorStatus.smokeStatus,
        colorBuilder: SensorStatus.smokeColor,
        safeRangeText: "< 600",
        tips: const [
          "Nếu tăng cao: mở cửa, bật quạt hút / thông gió.",
          "Tránh đặt cảm biến sát bếp hoặc nguồn khói.",
          "Kiểm tra nguồn mùi: gas, sơn, khói thuốc…",
        ],
      ),
    );
  }
}

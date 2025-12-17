import 'package:flutter/material.dart';

import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';
import 'history_chart_page.dart';

class DustPage extends StatelessWidget {
  const DustPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bụi mịn (PM)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Xem lịch sử",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryChartPage(
                    sensorKey: "dust_density",
                    title: "Bụi mịn (PM)",
                    unit: "µg/m³",
                    minY: 0,
                    maxY: 500,
                    color: Colors.redAccent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamChartPage(
        stream: db.getDustDensityStream(),
        maxY: 500,
        title: "", // ❗ tắt title trong chart
        unit: "µg/m³",
        statusBuilder: SensorStatus.dustStatus,
        colorBuilder: SensorStatus.dustColor,
        safeRangeText: "< 50 µg/m³",
        tips: const [
          "Nếu bụi cao: đóng cửa, bật máy lọc không khí.",
          "Vệ sinh phòng/khăn ướt để giảm bụi bay.",
          "Tránh đặt cảm biến gần cửa ra vào/cửa sổ.",
        ],
      ),
    );
  }
}

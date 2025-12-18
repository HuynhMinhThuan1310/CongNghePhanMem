import 'package:flutter/material.dart';

import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';
import 'history_chart_page.dart';

class HumChartPage extends StatelessWidget {
  const HumChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Độ ẩm"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Xem lịch sử",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryChartPage(
                    sensorKey: "do_am",
                    title: "Độ ẩm",
                    unit: "%",
                    minY: 0,
                    maxY: 100,
                    color: Colors.blue,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ===== BIỂU ĐỒ REALTIME =====
      body: StreamChartPage(
        stream: db.getHumidityStream(),
        maxY: 100,
        heartbeatStream: db.getLastSeenStream(),
        sampleInterval: const Duration(seconds: 3),
        title: "",
        historyPoints: 10,

        unit: "%",
        statusBuilder: SensorStatus.humStatus,
        colorBuilder: SensorStatus.humColor,
        safeRangeText: "40–60%",
        tips: const [
          "Duy trì 40–60% để giảm nấm mốc và khô da.",
          "Nếu quá ẩm: bật quạt thông gió / hút ẩm.",
          "Nếu quá khô: dùng máy tạo ẩm hoặc đặt khay nước.",
        ],
      ),
    );
  }
}

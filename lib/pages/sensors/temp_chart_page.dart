import 'package:flutter/material.dart';

import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';
import 'history_chart_page.dart';

class TempChartPage extends StatelessWidget {
  const TempChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhiệt độ"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Xem lịch sử",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HistoryChartPage(
                    sensorKey: "nhiet_do",
                    title: "Nhiệt độ",
                    unit: "°C",
                    minY: 0,
                    maxY: 40,
                    color: Colors.orange,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamChartPage(
        stream: db.getTemperatureStream(),
        maxY: 40,
        title: "", // ❗ tắt title trong chart
        unit: "°C",
        statusBuilder: SensorStatus.tempStatus,
        colorBuilder: SensorStatus.tempColor,
        safeRangeText: "20–28°C",
        tips: const [
          "20–28°C thường là dễ chịu cho sinh hoạt trong nhà.",
          "Nếu nóng: tăng thông gió / bật quạt / điều hòa.",
          "Nếu lạnh: đóng cửa, tránh gió lùa, cân nhắc sưởi.",
        ],
      ),
    );
  }
}

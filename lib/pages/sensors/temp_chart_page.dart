import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';

class TempChartPage extends StatelessWidget {
  const TempChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getTemperatureStream(),
      maxY: 50,
      title: "Nhiệt độ trong phòng",
      unit: "°C",
      statusBuilder: SensorStatus.tempStatus,
      colorBuilder: SensorStatus.tempColor,
      safeRangeText: "20–28°C",
      tips: const [
        "20–28°C thường là dễ chịu cho sinh hoạt trong nhà.",
        "Nếu nóng: tăng thông gió / bật quạt / điều hòa.",
        "Nếu lạnh: đóng cửa, tránh gió lùa, cân nhắc sưởi.",
      ],
    );
  }
}
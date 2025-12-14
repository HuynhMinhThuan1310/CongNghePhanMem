import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';

class HumChartPage extends StatelessWidget {
  const HumChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getHumidityStream(),
      maxY: 100,
      title: "Độ ẩm trong phòng",
      unit: "%",
      statusBuilder: SensorStatus.humStatus,
      colorBuilder: SensorStatus.humColor,
      safeRangeText: "40–60%",
      tips: const [
        "Duy trì 40–60% để giảm nấm mốc và khô da.",
        "Nếu quá ẩm: bật quạt thông gió / hút ẩm.",
        "Nếu quá khô: dùng máy tạo ẩm hoặc đặt khay nước.",
      ],
    );
  }
}

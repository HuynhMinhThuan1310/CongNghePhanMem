import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';

class DustPage extends StatelessWidget {
  const DustPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getDustDensityStream(),
      maxY: 500,
      title: "Bụi mịn (PM - density)",
      unit: " µg/m³",
      statusBuilder: SensorStatus.dustStatus,
      colorBuilder: SensorStatus.dustColor,
      safeRangeText: "< 50 µg/m³",
      tips: const [
        "Nếu bụi cao: đóng cửa, bật máy lọc không khí.",
        "Vệ sinh phòng/khăn ướt để giảm bụi bay.",
        "Tránh đặt cảm biến ngay cửa sổ/cửa ra vào (nhiễu).",
      ],
    );
  }
}

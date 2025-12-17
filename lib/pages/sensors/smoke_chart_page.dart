import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/services/sensor_status.dart';
import '/widgets/stream_chart_page.dart';

class SmokeChartPage extends StatelessWidget {
  const SmokeChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getSmokeStream(),
      maxY: 4500,
      title: "Chất lượng không khí (MQ135 raw)",
      unit: "",
      statusBuilder: SensorStatus.smokeStatus,
      colorBuilder: SensorStatus.smokeColor,
      safeRangeText: "< 600",
      valueFormatter: (v) => v.toStringAsFixed(0),
      tips: const [
        "Nếu tăng cao: mở cửa, bật quạt hút / thông gió.",
        "Tránh đặt cảm biến sát bếp/khói trực tiếp (sai lệch).",
        "Kiểm tra nguồn mùi: gas, sơn, hóa chất, khói thuốc…",
      ],
    );
  }
}
import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/widgets/stream_chart_page.dart';

class HumChartPage extends StatelessWidget {
  const HumChartPage({super.key});

  String humStatus(double h) {
    if (h < 30) return "Quá khô";
    if (h < 40) return "Khô";
    if (h < 60) return "Thoải mái";
    if (h < 70) return "Hơi ẩm";
    return "Quá ẩm";
  }

  Color humColor(double h) {
    if (h < 30) return Colors.red;
    if (h < 40) return Colors.orange;
    if (h < 60) return Colors.green;
    if (h < 70) return Colors.blue;
    return Colors.purple;
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getHumidityStream(),
      maxY: 100,
      title: "Độ ẩm hiện tại",
      statusBuilder: humStatus,
      colorBuilder: humColor,
      safeRangeText: "40–60%",
    );
  }
}

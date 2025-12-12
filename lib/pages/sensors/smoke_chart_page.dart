import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/widgets/stream_chart_page.dart';

class SmokeChartPage extends StatelessWidget {
  const SmokeChartPage({super.key});

  String smokeStatus(double v) {
    if (v < 500) return "An toàn";
    if (v < 1000) return "Nhẹ";
    if (v < 2000) return "Trung bình";
    return "Nguy hiểm";
  }

  Color smokeColor(double v) {
    if (v < 500) return Colors.green;
    if (v < 1000) return Colors.yellow;
    if (v < 2000) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getSmokeStream(),
      maxY: 2000,
      title: "Khí độc MQ135",
      statusBuilder: smokeStatus,
      colorBuilder: smokeColor,
      safeRangeText: "< 500",
    );
  }
}

import 'package:flutter/material.dart';
import '/services/firebase_database_service.dart';
import '/widgets/stream_chart_page.dart';

class DustPage extends StatelessWidget {
  const DustPage({super.key});

  String dustStatus(double d) {
    if (d < 50) return "Tốt";
    if (d < 100) return "Trung bình";
    if (d < 150) return "Kém";
    return "Nguy hiểm";
  }

  Color dustColor(double d) {
    if (d < 50) return Colors.green;
    if (d < 100) return Colors.yellow;
    if (d < 150) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final db = FirebaseDatabaseService();

    return StreamChartPage(
      stream: db.getDustDensityStream(),   // bạn có dust_voltage cũng được
      maxY: 200,
      title: "Bụi mịn (Density)",
      statusBuilder: dustStatus,
      colorBuilder: dustColor,
      safeRangeText: "< 50 µg/m³",
    );
  }
}

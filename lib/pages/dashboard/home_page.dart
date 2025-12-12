import 'package:flutter/material.dart';
import 'dashboard_page.dart';

import '../sensors/temp_chart_page.dart';
import '../sensors/hum_chart_page.dart';
import '../sensors/smoke_chart_page.dart';
import '../sensors/dust_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color appGreen = Color(0xFF66BB6A);
  static const Color appTeal = Color(0xFF26A69A);

  static const Color cTemp = Color(0xFFEF5350);
  static const Color cHum = Color(0xFF42A5F5);
  static const Color cGas = Color(0xFFFF7043);
  static const Color cDust = Color(0xFF8E24AA);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // ===== HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 50),
            decoration: const BoxDecoration(
              color: appGreen,
            ),
            child: const Column(
              children: [
                Icon(Icons.eco, size: 60, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  "Giám sát môi trường",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "ESP32C3 • Firebase • Real-time",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===== SENSOR GRID =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Cảm biến",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text("Chọn để xem dữ liệu chi tiết"),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.15,
                  children: [
                    _sensorCard(
                      context,
                      "Nhiệt độ",
                      Icons.thermostat,
                      cTemp,
                      const TempChartPage(),
                      "Nhiệt độ",
                    ),
                    _sensorCard(
                      context,
                      "Độ ẩm",
                      Icons.water_drop,
                      cHum,
                      const HumChartPage(),
                      "Độ ẩm",
                    ),
                    _sensorCard(
                      context,
                      "Khí gas",
                      Icons.smoke_free,
                      cGas,
                      const SmokeChartPage(),
                      "Khí gas",
                    ),
                    _sensorCard(
                      context,
                      "Bụi PM",
                      Icons.grain,
                      cDust,
                      const DustPage(),
                      "Bụi PM",
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sensorCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget page,
    String pageTitle,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DashboardPage(
                initialPage: page,
                initialTitle: pageTitle,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

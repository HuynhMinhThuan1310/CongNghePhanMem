import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const Color primaryGreen = Color(0xFF43A047);
  static const Color primaryTeal = Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giới thiệu dự án"),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryGreen, primaryTeal],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                "https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&q=80",
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- TITLE ----------------
            const Text(
              "Hệ thống giám sát môi trường thông minh",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // ---------------- DESCRIPTION ----------------
            Text(
              "Dự án sử dụng ESP32C3 kết hợp với các cảm biến DHT11, MQ135 và GP2Y10 để thu thập dữ liệu môi trường "
              "như nhiệt độ, độ ẩm, bụi mịn và khí độc. Tất cả dữ liệu được gửi lên Firebase Realtime Database "
              "và hiển thị trực quan theo thời gian thực trên ứng dụng Flutter.",
              style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
            ),

            const SizedBox(height: 30),

            // ---------------- TECHNOLOGIES ----------------
            _sectionTitle("Công nghệ sử dụng"),
            _tech(Icons.memory, "ESP32C3", "Vi điều khiển IoT"),
            _tech(Icons.sensors, "DHT11, MQ135, GP2Y10", "Các cảm biến môi trường"),
            _tech(Icons.cloud, "Firebase Realtime Database", "Lưu trữ & cập nhật liên tục"),
            _tech(Icons.phone_android, "Flutter", "Xây dựng ứng dụng đa nền tảng"),

            const SizedBox(height: 30),

            // ---------------- FEATURES ----------------
            _sectionTitle("Tính năng nổi bật"),
            _feature(Icons.update, "Cập nhật dữ liệu thời gian thực"),
            _feature(Icons.show_chart, "Biểu đồ trực quan dễ hiểu"),
            _feature(Icons.warning_amber, "Cảnh báo khi vượt ngưỡng"),
            _feature(Icons.history, "Lưu trữ lịch sử 30 điểm dữ liệu"),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ==================== COMPONENTS =====================

  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryTeal,          // 🌟 Màu đồng bộ
        ),
      ),
    );
  }

  Widget _tech(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: primaryTeal, size: 28), // 🌟 Teal đẹp
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _feature(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: primaryGreen, size: 24), // 🌟 Xanh lá nhấn mạnh
      title: Text(title),
      contentPadding: EdgeInsets.zero,
    );
  }
}

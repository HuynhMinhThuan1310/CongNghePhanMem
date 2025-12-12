import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';
import 'about_page.dart';

import '../sensors/temp_chart_page.dart';
import '../sensors/hum_chart_page.dart';
import '../sensors/smoke_chart_page.dart';
import '../sensors/dust_page.dart';
import '../sensors/conclusion_page.dart';
import '../authentication/change_password_page.dart';

class DashboardPage extends StatefulWidget {
  final Widget? initialPage;
  final String? initialTitle;

  const DashboardPage({
    super.key,
    this.initialPage,
    this.initialTitle,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Widget _currentPage;
  late String _currentTitle;

  static const Color appGreen = Color(0xFF66BB6A);

  // Custom palette
  static const Color cHome = Color(0xFF43A047);
  static const Color cTemp = Color(0xFFEF5350);
  static const Color cHum = Color(0xFF42A5F5);
  static const Color cGas = Color(0xFFFF7043);
  static const Color cDust = Color(0xFF8E24AA);
  static const Color cOverview = Color(0xFF26A69A);
  static const Color cInfo = Color(0xFF66BB6A);
  static const Color cPassword = Color(0xFFFBC02D);
  static const Color cLogout = Color(0xFFE53935);

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? const HomePage();
    _currentTitle = widget.initialTitle ?? "Trang chủ";
  }

  void _navigate(Widget page, String title) {
    Navigator.pop(context);
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        centerTitle: true,
        elevation: 1,
        backgroundColor: appGreen,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _drawerHeader(),

            _menuItem(Icons.home, "Trang chủ", cHome,
                () => _navigate(const HomePage(), "Trang chủ")),
            _divider(),

            _menuItem(Icons.thermostat, "Nhiệt độ", cTemp,
                () => _navigate(const TempChartPage(), "Nhiệt độ")),
            _menuItem(Icons.water_drop, "Độ ẩm", cHum,
                () => _navigate(const HumChartPage(), "Độ ẩm")),
            _menuItem(Icons.smoke_free, "Khí gas", cGas,
                () => _navigate(const SmokeChartPage(), "Khí gas")),
            _menuItem(Icons.grain, "Bụi (PM)", cDust,
                () => _navigate(const DustPage(), "Bụi (PM)")),
            _menuItem(Icons.dashboard_customize, "Tổng quan", cOverview,
                () => _navigate(const ConclusionPage(), "Tổng quan")),

            _divider(),

            _menuItem(Icons.info_outline, "Giới thiệu dự án", cInfo, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            }),

            _divider(),

            _menuItem(Icons.lock, "Đổi mật khẩu", cPassword, () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              );
            }),

            _menuItem(Icons.logout, "Đăng xuất", cLogout, () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            }),
          ],
        ),
      ),

      body: _currentPage,
    );
  }

  Widget _drawerHeader() {
    return DrawerHeader(
      decoration: const BoxDecoration(color: appGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: const [
          Icon(Icons.eco, size: 48, color: Colors.white),
          SizedBox(height: 8),
          Text(
            "Giám sát môi trường",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Hệ thống IoT",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 26),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey.shade300),
    );
  }
}

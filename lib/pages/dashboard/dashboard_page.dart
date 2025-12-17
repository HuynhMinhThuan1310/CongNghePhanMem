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

  const DashboardPage({super.key, this.initialPage, this.initialTitle});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget _currentPage = const SizedBox.shrink();
  String _currentTitle = "Trang chủ";

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialTitle ?? "Trang chủ";
    _currentPage = widget.initialPage ?? HomePage(onNavigate: _setPage);
  }

  void _setPage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
  }

  void _openFromDrawer(Widget page, String title) {
    Navigator.pop(context);
    _setPage(page, title);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.eco_rounded, size: 46, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Giám sát môi trường",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text("Hệ thống IoT trong nhà", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            _item(Icons.home_rounded, "Trang chủ", () => _openFromDrawer(HomePage(onNavigate: _setPage), "Trang chủ")),
            const Divider(),

            _item(Icons.thermostat_rounded, "Nhiệt độ", () => _openFromDrawer(const TempChartPage(), "Nhiệt độ")),
            _item(Icons.water_drop_rounded, "Độ ẩm", () => _openFromDrawer(const HumChartPage(), "Độ ẩm")),
            _item(Icons.air_rounded, "Khí gas", () => _openFromDrawer(const SmokeChartPage(), "Khí gas")),
            _item(Icons.grain_rounded, "Bụi (PM)", () => _openFromDrawer(const DustPage(), "Bụi (PM)")),
            _item(Icons.dashboard_customize_rounded, "Tổng quan", () => _openFromDrawer(const ConclusionPage(), "Tổng quan")),

            const Divider(),

            _item(Icons.info_outline_rounded, "Giới thiệu dự án", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutPage()));
            }),

            _item(Icons.lock_rounded, "Đổi mật khẩu", () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()));
            }),

            const Divider(),

            _item(Icons.logout_rounded, "Đăng xuất", _logout),
          ],
        ),
      ),
      body: SafeArea(child: _currentPage),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }
}
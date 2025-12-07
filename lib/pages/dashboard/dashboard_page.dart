import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import '../sensors/temp_chart_page.dart';
import '../sensors/hum_chart_page.dart';
import '../sensors/smoke_chart_page.dart';
import '../sensors/dust_page.dart';
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

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage ?? const HomePage();
    _currentTitle = widget.initialTitle ?? 'Trang chủ';
  }

  void _navigateToPage(Widget page, String title) {
    setState(() {
      _currentPage = page;
      _currentTitle = title;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTitle),
        centerTitle: true,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.eco,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Giám sát môi trường',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Hệ thống IoT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () => _navigateToPage(const HomePage(), 'Trang chủ'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.thermostat),
              title: const Text('Nhiệt độ'),
              onTap: () => _navigateToPage(const TempChartPage(), 'Nhiệt độ'),
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Độ ẩm'),
              onTap: () => _navigateToPage(const HumChartPage(), 'Độ ẩm'),
            ),
            ListTile(
              leading: const Icon(Icons.smoke_free),
              title: const Text('Cảm biến khói'),
              onTap: () => _navigateToPage(const SmokeChartPage(), 'Cảm biến khói'),
            ),
            ListTile(
              leading: const Icon(Icons.grain),
              title: const Text('Bụi (PM)'),
              onTap: () => _navigateToPage(const DustPage(), 'Bụi (PM)'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async {
                Navigator.pop(context);
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      body: _currentPage,
    );
  }
}

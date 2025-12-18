import 'package:flutter/material.dart';
import '../../services/firebase_auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _authService = FirebaseAuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = "Vui lòng nhập email.");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await _authService.sendPasswordResetEmail(email);

      setState(() {
        _successMessage =
            "Nếu email tồn tại, hệ thống đã gửi liên kết khôi phục. Vui lòng kiểm tra hộp thư.";
      });
    } on Exception catch (_) {
      setState(() {
        _errorMessage =
            "Không thể gửi yêu cầu khôi phục. Vui lòng thử lại sau.";
      });
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Khôi phục mật khẩu"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const Text(
            "Nhập email để nhận liên kết đặt lại mật khẩu.",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "Nhập email",
              prefixIcon: const Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),

          if (_errorMessage != null)
            _msgBox(_errorMessage!, Colors.red),

          if (_successMessage != null)
            _msgBox(_successMessage!, Colors.green),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Gửi email khôi phục",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _msgBox(String msg, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            color == Colors.red ? Icons.error : Icons.check_circle,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
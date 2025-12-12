import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';
import 'forgot_password_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showEmailError = false;
  bool _showPasswordError = false;

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    setState(() {
      _showEmailError = _emailController.text.isNotEmpty &&
          !_authService.isValidEmail(_emailController.text.trim());
    });
  }

  void _validatePassword() {
    setState(() {
      _showPasswordError =
          _passwordController.text.isNotEmpty &&
              _passwordController.text.length < 6;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final token = _tokenController.text.trim();

    if (!_authService.isValidEmail(email)) {
      setState(() {
        _errorMessage =
            'Email không hợp lệ. Vui lòng nhập đúng định dạng (ví dụ: user@example.com).';
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Mật khẩu phải có ít nhất 6 kí tự.';
        _isLoading = false;
      });
      return;
    }

    if (!_isLogin && name.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên của bạn.';
        _isLoading = false;
      });
      return;
    }

    if (!_isLogin && password != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu xác nhận không trùng khớp.';
        _isLoading = false;
      });
      return;
    }

    if (!_isLogin && token.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã xác thực Token.';
        _isLoading = false;
      });
      return;
    }

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          email: email,
          password: password,
        );
      } else {
        await _authService.signUpWithEmail(
          email: email,
          password: password,
          name: name,
          token: token,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _authService.getErrorMessage(e.code);
        _isLoading = false;
      });
      return;
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi không xác định: ${e.toString()}';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  _isLogin ? 'Đăng nhập' : 'Đăng ký',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Tên của bạn',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText:
                      _showEmailError ? 'Email không hợp lệ' : null,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: 'Mật khẩu (tối thiểu 6 kí tự)',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: _showPasswordError
                          ? 'Mật khẩu phải có ít nhất 6 kí tự'
                          : null,
                    ),
                    obscureText: true,
                  ),
                ),

                // ⭐ NÚT QUÊN MẬT KHẨU ⭐
                if (_isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Quên mật khẩu?",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        hintText: 'Xác nhận mật khẩu',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      obscureText: true,
                    ),
                  ),

                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _tokenController,
                      decoration: InputDecoration(
                        hintText: 'Mã Token (Trên thiết bị của bạn)',
                        prefixIcon: const Icon(Icons.verified_user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      _isLogin ? 'Đăng nhập' : 'Đăng ký',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin
                          ? 'Chưa có tài khoản? '
                          : 'Đã có tài khoản? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _emailController.clear();
                          _passwordController.clear();
                          _confirmPasswordController.clear();
                          _nameController.clear();
                          _tokenController.clear();
                          _showEmailError = false;
                          _showPasswordError = false;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Đăng ký' : 'Đăng nhập',
                        style: TextStyle(
                          color: Colors.green.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

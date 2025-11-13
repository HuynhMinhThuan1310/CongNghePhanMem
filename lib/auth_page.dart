import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Token xác thực (có thể thay bằng lấy từ Firebase)
  static const String VALID_TOKEN = "DLMT2024";

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    setState(() {
      _showEmailError = _emailController.text.isNotEmpty && !_isValidEmail(_emailController.text.trim());
    });
  }

  void _validatePassword() {
    setState(() {
      _showPasswordError = _passwordController.text.isNotEmpty && _passwordController.text.length < 6;
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

    // Validation
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final name = _nameController.text.trim();
    final token = _tokenController.text.trim();

    // Kiểm tra email hợp lệ
    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Email không hợp lệ. Vui lòng nhập email đúng định dạng (ví dụ: user@example.com)';
        _isLoading = false;
      });
      return;
    }

    // Kiểm tra mật khẩu
    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Mật khẩu phải có ít nhất 6 kí tự';
        _isLoading = false;
      });
      return;
    }

    // Kiểm tra tên khi đăng ký
    if (!_isLogin && name.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập tên của bạn';
        _isLoading = false;
      });
      return;
    }

    // Kiểm tra xác nhận mật khẩu khi đăng ký
    if (!_isLogin && password != confirmPassword) {
      setState(() {
        _errorMessage = 'Mật khẩu và xác nhận mật khẩu không trùng khớp';
        _isLoading = false;
      });
      return;
    }

    // Kiểm tra token khi đăng ký
    if (!_isLogin && token.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã xác thực để đăng ký';
        _isLoading = false;
      });
      return;
    }

    // Kiểm tra token hợp lệ
    if (!_isLogin && token != VALID_TOKEN) {
      setState(() {
        _errorMessage = 'Mã Token không đúng. Vui lòng kiểm tra lại.';
        _isLoading = false;
      });
      return;
    }

    try {
      if (_isLogin) {
        // Đăng nhập
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        // Đăng ký
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Cập nhật display name
        await userCredential.user?.updateDisplayName(name);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
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

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tìm thấy. Vui lòng kiểm tra email hoặc đăng ký tài khoản mới.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng thử lại.';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng. Vui lòng kiểm tra lại.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng sử dụng email khác hoặc đăng nhập với tài khoản này.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu có ít nhất 6 kí tự.';
      case 'invalid-email':
        return 'Email không hợp lệ. Vui lòng nhập đúng định dạng email.';
      case 'operation-not-allowed':
        return 'Đăng ký bị vô hiệu hóa. Vui lòng liên hệ quản trị viên.';
      case 'too-many-requests':
        return 'Bạn đã cố gắng đăng nhập quá nhiều lần. Vui lòng thử lại sau.';
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      default:
        return 'Lỗi xác thực: $code. Vui lòng thử lại.';
    }
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
                // Logo/Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.eco,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),

                // Tiêu đề
                Text(
                  _isLogin ? 'Đăng nhập' : 'Đăng ký',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin
                      ? 'Chào mừng trở lại!'
                      : 'Tạo tài khoản mới',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Form
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

                // Email field
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
                      errorText: _showEmailError ? 'Email không hợp lệ' : null,
                      errorBorder: _showEmailError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            )
                          : null,
                      focusedErrorBorder: _showEmailError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),

                // Password field
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                      errorText: _showPasswordError ? 'Mật khẩu phải có ít nhất 6 kí tự' : null,
                      errorBorder: _showPasswordError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            )
                          : null,
                      focusedErrorBorder: _showPasswordError
                          ? OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    obscureText: true,
                  ),
                ),

                // Confirm password field (chỉ khi đăng ký)
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

                // Token field (chỉ khi đăng ký)
                if (!_isLogin)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextField(
                      controller: _tokenController,
                      decoration: InputDecoration(
                        hintText: 'Mã Token (Trên Thiết Bị của Bạn)',
                        prefixIcon: const Icon(Icons.verified_user),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Tooltip(
                          message: 'Bạn cần mã xác thực để đăng ký. Vui lòng liên hệ quản trị viên.',
                          child: Icon(Icons.info_outline, color: Colors.grey[600]),
                        ),
                      ),
                    ),
                  ),

                // Error message
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

                // Auth button
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
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
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

                // Toggle between login/register
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
                    ),
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

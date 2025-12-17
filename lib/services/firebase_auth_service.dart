import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static const String validToken = "DLMT2024";

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// -------------------------
  /// Validate Email
  /// -------------------------
  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }
  Future<void> sendPasswordResetEmail(String email) async {
  await _auth.sendPasswordResetEmail(email: email);
}

String getResetPasswordErrorMessage(String code) {
  switch (code) {
    case "invalid-email":
      return "Email không hợp lệ. Vui lòng nhập đúng định dạng.";
    case "user-not-found":
      return "Email này chưa được đăng ký.";
    case "missing-email":
      return "Vui lòng nhập email.";
    default:
      return "Không thể gửi email khôi phục mật khẩu. Lỗi: $code";
  }
}


  /// -------------------------
  /// Sign Up
  /// -------------------------
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String token,
  }) async {
    if (token != validToken) {
      throw FirebaseAuthException(
        code: 'invalid-token',
        message: 'Mã Token không đúng',
      );
    }

    final credential =
        await _auth.createUserWithEmailAndPassword(email: email, password: password);

    await credential.user?.updateDisplayName(name);

    return credential;
  }
    String getChangePasswordErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Mật khẩu hiện tại không đúng.';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu (tối thiểu 6 ký tự).';
      case 'user-not-found':
        return 'Không tìm thấy người dùng.';
      case 'requires-recent-login':
        return 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ. Vui lòng kiểm tra lại.';
      default:
        return 'Đã xảy ra lỗi: $code';
    }
  }


  /// -------------------------
  /// Sign In
  /// -------------------------
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// -------------------------
  /// Logout
  /// -------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// -------------------------
  /// Change Password
  /// -------------------------
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: "user-not-found",
        message: "Không tìm thấy người dùng",
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  /// -------------------------
  /// Error Handler
  /// -------------------------
  String getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
      case 'invalid-token':
        return 'Mã Token không đúng';
      default:
        return 'Lỗi: $code';
    }
  }
}
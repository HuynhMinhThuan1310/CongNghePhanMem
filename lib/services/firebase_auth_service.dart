import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  static const String VALID_TOKEN = "DLMT2024";
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String token,
  }) async {
    if (token != VALID_TOKEN) {
      throw FirebaseAuthException(
        code: 'invalid-token',
        message: 'Mã Token không đúng',
      );
    }

    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user?.email == null) throw Exception('Không tìm thấy người dùng');

    final credential = EmailAuthProvider.credential(
      email: user!.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  bool isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  String getErrorMessage(String code) {
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
      case 'invalid-token':
        return 'Mã Token không đúng. Vui lòng kiểm tra lại.';
      default:
        return 'Lỗi xác thực: $code. Vui lòng thử lại.';
    }
  }

  String getChangePasswordErrorMessage(String code) {
    switch (code) {
      case 'wrong-password':
        return 'Mật khẩu hiện tại không đúng';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu (tối thiểu 6 ký tự)';
      case 'user-not-found':
        return 'Không tìm thấy người dùng';
      case 'requires-recent-login':
        return 'Vui lòng đăng nhập lại để đổi mật khẩu';
      default:
        return 'Lỗi: $code';
    }
  }
}

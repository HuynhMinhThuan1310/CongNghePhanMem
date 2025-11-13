# Hướng dẫn Mã Xác Thực Đăng Ký

## Token Xác Thực

Để đăng ký tài khoản mới trong ứng dụng, bạn **cần mã xác thực**.

### Mã xác thực hiện tại:
```
DLMT2024
```

## Cách Đổi Token

Để thay đổi mã xác thực, chỉnh sửa file `lib/auth_page.dart`:

```dart
static const String VALID_TOKEN = "DLMT2024";  // Thay bằng token mới
```

### Ví dụ:
```dart
static const String VALID_TOKEN = "MONITORING2024";
```

## Quy Trình Đăng Ký

1. Mở ứng dụng
2. Chọn **"Đăng ký"**
3. Nhập **Tên** của bạn
4. Nhập **Email**
5. Nhập **Mật khẩu** (tối thiểu 6 kí tự)
6. Nhập **Xác nhận mật khẩu**
7. Nhập **Mã xác thực** (DLMT2024)
8. Nhấn **Đăng ký**

## Lợi Ích

- ✅ Ngăn chặn spam đăng ký
- ✅ Kiểm soát số lượng người dùng
- ✅ Chỉ cho phép người được phép đăng ký
- ✅ Bảo vệ ứng dụng

## Nâng Cao

Bạn có thể:
- Lưu token trong Firebase Realtime Database
- Sử dụng token duy nhất cho từng người dùng
- Tạo hệ thống quản lý token
- Tích hợp với email xác thực

---
**Lưu ý:** Đây là phương pháp cơ bản. Cho các ứng dụng sản xuất, xem xét sử dụng email verification hoặc hệ thống invite link.

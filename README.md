# DLMT – Giám sát môi trường (ESP32 + Firebase + Flutter)

## 1) Giới thiệu
Đồ án Công Nghệ Phần Mềm: Hệ thống giám sát môi trường trong phòng sử dụng **ESP32 (ESP32-C3)** đọc dữ liệu cảm biến và đẩy lên **Firebase Realtime Database**, ứng dụng **Flutter** hiển thị dữ liệu realtime + biểu đồ theo thời gian.

Repo gồm:
- **App Flutter** (thư mục `lib`, `android`, `ios`, `web`, ...).  
- **Code cho ESP32** (thư mục `code-esp/CodeESP`).  
- **Cấu hình deploy web** (có `firebase.json`). :contentReference[oaicite:1]{index=1}

---

## 2) Chức năng chính
- ESP32 đọc dữ liệu cảm biến (ví dụ: nhiệt độ/độ ẩm/khí gas/bụi) và gửi lên Firebase theo chu kỳ.
- App Flutter:
  - Xem chỉ số realtime.
  - Xem biểu đồ (line chart) theo thời gian + cảnh báo trạng thái.
  - (Tuỳ phiên bản) Lưu lịch sử theo ngày/giờ trên Firebase.

---

## 3) Công nghệ sử dụng
- **ESP32-C3** + cảm biến (DHT11, MQ135, GP2Y1010AU0F).
- **Firebase Realtime Database** (stream realtime).
- **Flutter** (Android/Web).
- (Tuỳ chọn) **Firebase Hosting** để deploy bản web.

---

## 4) Cấu trúc thư mục
- `lib/` : mã nguồn Flutter (UI, pages, services…)
- `code-esp/CodeESP/` : mã nguồn ESP32
- `web/` : cấu hình Flutter web
- `firebase.json` : cấu hình deploy Firebase Hosting (nếu dùng) :contentReference[oaicite:2]{index=2}

---

## 5) Cài đặt & chạy App Flutter

### 5.1. Yêu cầu môi trường
- Flutter SDK (khuyến nghị dùng bản stable mới)
- Android Studio (chạy Android) / Chrome (chạy Web)
- Kết nối Internet (để lấy package + kết nối Firebase)

### 5.2. Chạy lần đầu
```bash
# tại thư mục gốc repo
flutter pub get

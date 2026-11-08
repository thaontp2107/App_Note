# Note App (Flutter)

Ứng dụng ghi chú đơn giản viết bằng Flutter/Dart, **không dùng backend** — dữ liệu được lưu cục bộ trên thiết bị bằng `shared_preferences`.

## Chức năng

- **Thêm ghi chú**: nhấn nút **"Thêm ghi chú"** ở góc dưới, nhập tiêu đề + nội dung, nhấn ✓ để lưu.
- **Chỉnh sửa ghi chú**: chạm vào một ghi chú trong danh sách, sửa rồi nhấn ✓.
- **Xóa ghi chú**: nhấn biểu tượng thùng rác, hoặc vuốt ghi chú sang trái, hoặc nhấn thùng rác trong màn hình sửa. Có hộp thoại xác nhận và nút **Hoàn tác**.
- **Hiển thị danh sách**: ghi chú mới cập nhật nằm trên cùng, hiển thị tiêu đề, 2 dòng nội dung và thời gian cập nhật.
- Dữ liệu vẫn còn sau khi tắt/mở lại ứng dụng.

## Cấu trúc thư mục

```
lib/
├── main.dart                     # Điểm khởi chạy, cấu hình theme
├── models/
│   └── note.dart                 # Model Note (id, title, content, createdAt, updatedAt) + JSON
├── services/
│   └── note_storage.dart         # Đọc/ghi danh sách ghi chú vào SharedPreferences
└── screens/
    ├── note_list_screen.dart     # Màn hình danh sách (thêm / xóa / mở sửa)
    └── note_edit_screen.dart     # Màn hình thêm / sửa ghi chú
test/
└── widget_test.dart              # Test luồng thêm → sửa → xóa
```

## Yêu cầu

- Flutter SDK 3.x (đã kiểm tra với Flutter 3.47 / Dart 3.13) — cài theo https://docs.flutter.dev/get-started/install
- Một trong các thiết bị chạy: Android emulator/điện thoại, iOS simulator (macOS), Chrome (web) hoặc desktop (Windows/macOS/Linux).

Kiểm tra môi trường:

```bash
flutter doctor
```

## Cách chạy

```bash
# 1. Vào thư mục dự án
cd note_app

# 2. Tải các package
flutter pub get

# 3. Xem các thiết bị đang có
flutter devices

# 4. Chạy ứng dụng
flutter run                 # chọn thiết bị khi được hỏi
# hoặc chỉ định thiết bị:
flutter run -d chrome       # chạy trên trình duyệt
flutter run -d android      # chạy trên Android emulator / điện thoại
flutter run -d windows      # hoặc macos / linux
```

Khi đang chạy, nhấn `r` để hot reload, `R` để hot restart, `q` để thoát.

## Chạy test & kiểm tra code

```bash
flutter analyze
flutter test
```

## Build bản phát hành

```bash
flutter build apk --release     # Android -> build/app/outputs/flutter-apk/app-release.apk
flutter build web               # Web     -> build/web/
flutter build ios --release     # iOS (cần macOS + Xcode)
```

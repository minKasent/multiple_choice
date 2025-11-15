# Flutter App Setup Guide

## 📋 Yêu Cầu

- Flutter SDK 3.8.1+
- Dart SDK 3.8.0+
- Android Studio / Xcode (cho build native)
- Visual Studio Code / IntelliJ IDEA (khuyến nghị)

## 🚀 Cài Đặt Nhanh

### 1. Clone project và cài dependencies

```bash
cd app
flutter pub get
```

### 2. Generate code (REQUIRED!)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Lệnh này sẽ generate:
- `*.freezed.dart` - Immutable models
- `*.g.dart` - JSON serialization
- `*.config.dart` - Dependency injection
- `*.gr.dart` - Router code

### 3. Cấu hình API URL

Mở `lib/core/constants/api_constants.dart` và sửa baseUrl:

```dart
static const String baseUrl = 'http://YOUR_IP:8080/api';
// Ví dụ: 'http://192.168.1.100:8080/api'
```

⚠️ **Lưu ý**: 
- Không dùng `localhost` hay `127.0.0.1` khi chạy trên thiết bị thật
- Sử dụng IP của máy backend trên cùng mạng
- Hoặc dùng `10.0.2.2` cho Android Emulator

### 4. Run app

```bash
# Development mode
flutter run

# Release mode
flutter run --release
```

## 🔧 Cấu Hình Google Sign In

### Android

1. Tạo project trên [Firebase Console](https://console.firebase.google.com)
2. Download `google-services.json` 
3. Copy vào `android/app/`
4. Thêm vào `android/build.gradle`:

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
}
```

5. Thêm vào `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### iOS

1. Download `GoogleService-Info.plist`
2. Copy vào `ios/Runner/`
3. Open `ios/Runner.xcworkspace` trong Xcode
4. Đảm bảo file được add vào project

## 📝 Code Generation

### Watch mode (auto generate khi file thay đổi)

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### One-time generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Clean và regenerate

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🏗️ Kiến Trúc

```
lib/
├── core/                  # Core utilities
│   ├── constants/        # Constants
│   ├── di/              # Dependency Injection (get_it + injectable)
│   ├── network/         # API client, interceptors
│   ├── router/          # AutoRoute navigation
│   ├── theme/           # Theme, colors, text styles
│   └── utils/           # Extensions, validators
├── features/            # Features (Clean Architecture)
│   └── [feature]/
│       ├── data/        # Data sources, models, repositories impl
│       ├── domain/      # Entities, repositories, use cases
│       └── presentation/# BLoC, pages, widgets
└── shared/              # Shared components
    ├── models/          # Shared models
    └── widgets/         # Reusable widgets
```

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 📦 Build

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (cho Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
flutter build ios --release
```

Sau đó mở Xcode để archive và upload lên App Store.

## 🐛 Troubleshooting

### Lỗi: "No pubspec.yaml file found"

```bash
# Đảm bảo bạn đang ở đúng thư mục
cd app
```

### Lỗi: "The name X isn't defined"

```bash
# Chạy code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Lỗi: "MissingPluginException"

```bash
# Uninstall app và rebuild
flutter clean
flutter pub get
flutter run
```

### Lỗi network trên Android

Kiểm tra:
1. Đã thêm `INTERNET` permission trong `AndroidManifest.xml` ✅
2. API URL đúng (không dùng localhost)
3. Backend đang chạy và accessible

### Lỗi: "Version solving failed"

```bash
# Xóa cache và reinstall
flutter pub cache repair
flutter pub get
```

## 📱 Chạy trên thiết bị

### Android

1. Bật Developer mode trên thiết bị
2. Bật USB Debugging
3. Kết nối qua USB
4. Chạy `flutter devices` để check
5. `flutter run`

### iOS

1. Đăng ký Apple Developer account
2. Open project trong Xcode
3. Chọn team và signing
4. Run từ Xcode hoặc `flutter run`

## 🔑 Credentials Mặc Định

```
Email:    admin@exam.com
Password: Admin@123
```

## 📚 Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Dart Documentation](https://dart.dev/guides)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev)

## ❓ Cần Trợ Giúp?

1. Check [README.md](README.md) 
2. Check lỗi trong console
3. Google error message
4. Stack Overflow
5. Flutter Discord/Reddit

---

Happy Coding! 🎉


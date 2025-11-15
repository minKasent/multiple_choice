# Exam System - Mobile App

Ứng dụng di động cho hệ thống thi trắc nghiệm với Flutter.

## 📱 Tính năng

### Admin
- Quản lý người dùng (Teacher, Proctor, Student)
- Quản lý môn học
- Xem thống kê tổng quan

### Teacher  
- Quản lý ngân hàng câu hỏi (Subject > Chapter > Passage > Question)
- Tạo và trộn đề thi
- Xem kết quả và thống kê

### Student
- Xem danh sách bài thi
- Làm bài thi trắc nghiệm
- Xem kết quả và lịch sử

## 🏗️ Kiến trúc

Clean Architecture với 3 layers:

```
lib/
├── core/                 # Core utilities
│   ├── constants/       # API, App, Storage constants
│   ├── di/             # Dependency Injection
│   ├── errors/         # Exceptions & Failures
│   ├── network/        # API Client, Interceptors
│   ├── router/         # AutoRoute navigation
│   ├── theme/          # Colors, TextStyles, Theme
│   └── utils/          # Extensions, Validators
├── features/           # Features (Clean Architecture)
│   ├── auth/
│   │   ├── data/       # DataSources, Models, Repositories
│   │   ├── domain/     # Entities, Repositories, UseCases
│   │   └── presentation/ # BLoC, Pages, Widgets
│   ├── dashboard/
│   ├── exam/
│   ├── question_bank/
│   └── statistics/
└── shared/             # Shared components
    ├── models/         # API Response, User Model
    └── widgets/        # Reusable widgets
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.8+
- **State Management**: flutter_bloc (Cubit)
- **Dependency Injection**: get_it + injectable
- **Navigation**: auto_route
- **Network**: dio + retrofit
- **Storage**: flutter_secure_storage, shared_preferences, hive
- **Auth**: Google Sign In
- **Code Generation**: freezed, json_serializable

## 🚀 Setup

### 1. Cài đặt dependencies

```bash
flutter pub get
```

### 2. Generate code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Cấu hình API

Sửa `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:8080/api';
```

### 4. Run app

```bash
# Development
flutter run

# Release
flutter run --release
```

## 📦 Build

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## 🧪 Testing

```bash
flutter test
```

## 📝 Code Generation Commands

```bash
# Watch mode (auto generate on file change)
flutter pub run build_runner watch --delete-conflicting-outputs

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🎨 UI/UX

- **Design System**: Material Design 3
- **Font**: Inter (Google Fonts)
- **Theme**: Light & Dark mode
- **Colors**: Định nghĩa trong `core/theme/app_colors.dart`
- **Responsive**: Hỗ trợ nhiều kích thước màn hình

## 🔐 Authentication

- Email/Password login
- Google Sign In (OAuth2)
- JWT Token với auto refresh
- Secure storage cho tokens

## 📂 Features Status

- ✅ Core setup (DI, Network, Router, Theme)
- ✅ Auth (Login, Register, Google Sign In)
- ✅ Dashboard (Admin, Teacher, Student)
- ⏳ User Management
- ⏳ Question Bank Management
- ⏳ Exam Management
- ⏳ Take Exam
- ⏳ Statistics

## 🤝 Best Practices

✅ Clean Architecture
✅ SOLID Principles
✅ Dependency Injection
✅ State Management (Cubit)
✅ Error Handling
✅ Code Generation
✅ Responsive UI
✅ Type Safety
✅ Immutable State (Freezed)

## 📱 Screenshots

_(Coming soon)_

## 🐛 Known Issues

- Code generation cần chạy sau khi thêm models mới
- Google Sign In cần config trên Firebase Console

## 📞 Contact

- Email: support@examapp.com
- Website: https://examapp.com

# Hệ Thống Thi Trắc Nghiệm (Multiple Choice Exam System)

Hệ thống quản lý thi trắc nghiệm với backend Spring Boot và mobile app Flutter.

## 🚀 Yêu Cầu Hệ Thống

### Backend
- Java 17+
- PostgreSQL 14+
- Maven 3.8+

### Mobile App
- Flutter 3.8.1+
- Dart 3.8.1+
- Android Studio / VS Code

## 📦 Cài Đặt & Chạy

### 1. Database
```bash
# Tạo database PostgreSQL
createdb exam_system_dev

# Import schema
psql -U postgres -d exam_system_dev -f backend/database/schema.sql
```

### 2. Backend
```bash
cd backend/backend

# Chạy server (tự động tạo user admin nếu chưa có)
./mvnw spring-boot:run

# Backend chạy tại: http://localhost:8080/api
# Swagger UI: http://localhost:8080/api/swagger-ui.html
```

**Tài khoản mặc định:**
- Admin: Email: admin@gmail.com / 123456

### 3. Mobile App
```bash
cd app

# Cài đặt dependencies
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Cấu hình API URL
# Sửa file: lib/core/constants/api_constants.dart
# Đổi baseUrl thành IP máy của bạn (VD: http://192.168.1.14:8080/api)

# Chạy app
flutter run
```

## 📱 Chức Năng

### Admin/Teacher
- Quản lý người dùng, môn học, phòng thi
- Tạo ngân hàng câu hỏi (chương, đoạn văn, câu hỏi)
- Tạo và quản lý đề thi
- Xếp lịch thi cho sinh viên
- Xem thống kê và báo cáo

### Student
- Xem danh sách bài thi được phân công
- Làm bài thi online
- Xem kết quả và thống kê cá nhân

## 🔧 Cấu Hình

### Backend
- File cấu hình: `backend/backend/src/main/resources/application-dev.yml`
- Database, JWT secret, CORS settings

### Flutter App
- API URL: `app/lib/core/constants/api_constants.dart`

## 📚 Công Nghệ

**Backend:** Spring Boot, Spring Security, PostgreSQL, JWT, Swagger

**Mobile:** Flutter, Bloc/Cubit, GetIt, Dio, Freezed, Auto Route

## 🐛 Lưu Ý

- Backend cần chạy trước khi chạy mobile app
- Đảm bảo database đã được tạo và schema đã import
- Trên Android emulator, dùng IP `10.0.2.2` để connect localhost
- Trên thiết bị thật, dùng IP máy trong cùng mạng LAN

## 📄 License

MIT License


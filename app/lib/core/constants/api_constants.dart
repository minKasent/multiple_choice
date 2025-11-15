class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on host machine
  // Use your actual IP address (e.g., 192.168.x.x) for physical device
  static const String baseUrl = 'http://192.168.1.14:8080/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String profile = '/users/profile';

  // User endpoints
  static const String users = '/users';
  static const String updateProfile = '/users/profile';
  static const String changePassword = '/users/change-password';

  // Subject endpoints
  static const String subjects = '/subjects';

  // Question Bank endpoints
  static const String questionBank = '/question-bank';
  static const String chapters = '/question-bank/chapters';
  static const String passages = '/question-bank/passages';
  static const String questions = '/question-bank/questions';

  // Exam endpoints
  static const String exams = '/exams';
  static const String examSessions = '/exam-sessions';
  static const String myExams = '/exam-sessions/my-exams';
  static const String examRooms = '/exam-rooms';

  // Statistics endpoints
  static const String statistics = '/statistics';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

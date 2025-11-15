class AppConstants {
  static const String appName = 'Exam System';
  static const String appVersion = '1.0.0';
  
  // Roles
  static const String roleAdmin = 'ADMIN';
  static const String roleTeacher = 'TEACHER';
  static const String roleProctor = 'PROCTOR';
  static const String roleStudent = 'STUDENT';
  
  // Question types
  static const String questionTypeMultipleChoice = 'MULTIPLE_CHOICE';
  static const String questionTypeFillBlank = 'FILL_BLANK';
  
  // Exam statuses
  static const String examStatusDraft = 'DRAFT';
  static const String examStatusScheduled = 'SCHEDULED';
  static const String examStatusInProgress = 'IN_PROGRESS';
  static const String examStatusCompleted = 'COMPLETED';
  static const String examStatusCancelled = 'CANCELLED';
  
  // Session statuses
  static const String sessionStatusScheduled = 'SCHEDULED';
  static const String sessionStatusInProgress = 'IN_PROGRESS';
  static const String sessionStatusCompleted = 'COMPLETED';
  static const String sessionStatusAbsent = 'ABSENT';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}


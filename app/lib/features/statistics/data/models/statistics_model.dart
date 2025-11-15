import 'package:freezed_annotation/freezed_annotation.dart';

part 'statistics_model.freezed.dart';
part 'statistics_model.g.dart';

@freezed
class StudentStatsModel with _$StudentStatsModel {
  const factory StudentStatsModel({
    required int studentId,
    required String studentName,
    required int totalExamsTaken,
    required int totalExamsPassed,
    required int totalExamsFailed,
    required double averageScore,
    required double highestScore,
    required double lowestScore,
    required int totalViolations,
    required List<SubjectPerformanceModel> subjectPerformances,
  }) = _StudentStatsModel;

  factory StudentStatsModel.fromJson(Map<String, dynamic> json) =>
      _$StudentStatsModelFromJson(json);
}

@freezed
class SubjectPerformanceModel with _$SubjectPerformanceModel {
  const factory SubjectPerformanceModel({
    required String subjectName,
    required int examsTaken,
    required double averageScore,
  }) = _SubjectPerformanceModel;

  factory SubjectPerformanceModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectPerformanceModelFromJson(json);
}

@freezed
class ExamStatsModel with _$ExamStatsModel {
  const factory ExamStatsModel({
    required int examId,
    required String examTitle,
    required int totalSessions,
    required int completedSessions,
    required int passedSessions,
    required double passRate,
    required double averageScore,
    required double highestScore,
    required double lowestScore,
    required List<QuestionDifficultyModel> questionDifficulties,
  }) = _ExamStatsModel;

  factory ExamStatsModel.fromJson(Map<String, dynamic> json) =>
      _$ExamStatsModelFromJson(json);
}

@freezed
class QuestionDifficultyModel with _$QuestionDifficultyModel {
  const factory QuestionDifficultyModel({
    required int questionId,
    required String content,
    required int totalAttempts,
    required int correctAttempts,
    required double correctRate,
  }) = _QuestionDifficultyModel;

  factory QuestionDifficultyModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionDifficultyModelFromJson(json);
}

@freezed
class SubjectStatsModel with _$SubjectStatsModel {
  const factory SubjectStatsModel({
    required int subjectId,
    required String subjectName,
    required int totalChapters,
    required int totalQuestions,
    required int totalExams,
    required int totalSessions,
    required double averageScore,
  }) = _SubjectStatsModel;

  factory SubjectStatsModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectStatsModelFromJson(json);
}

@freezed
class DashboardStatsModel with _$DashboardStatsModel {
  const factory DashboardStatsModel({
    required int totalUsers,
    required int totalStudents,
    required int totalTeachers,
    required int totalSubjects,
    required int totalQuestions,
    required int totalExams,
    required int totalSessions,
    required int completedSessions,
    required double overallAverageScore,
    required double overallPassRate,
  }) = _DashboardStatsModel;

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsModelFromJson(json);
}

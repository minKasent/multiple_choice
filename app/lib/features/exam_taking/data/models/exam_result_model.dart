import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_result_model.freezed.dart';
part 'exam_result_model.g.dart';

@freezed
class ExamResultModel with _$ExamResultModel {
  const factory ExamResultModel({
    required int sessionId,
    required String sessionCode,
    required String examTitle,
    required String studentName,
    required DateTime completedAt,
    required double totalScore,
    required double maxScore,
    required double percentageScore,
    required bool isPassed,
    required double passingScore,
    required int correctAnswers,
    required int totalQuestions,
    required int violationCount,
    List<QuestionResultModel>? questionResults,
  }) = _ExamResultModel;

  factory ExamResultModel.fromJson(Map<String, dynamic> json) =>
      _$ExamResultModelFromJson(json);
}

@freezed
class QuestionResultModel with _$QuestionResultModel {
  const factory QuestionResultModel({
    required int questionId,
    required String content,
    String? studentAnswer,
    required String correctAnswer,
    required bool isCorrect,
    required double pointsEarned,
    required double maxPoints,
    String? explanation,
  }) = _QuestionResultModel;

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionResultModelFromJson(json);
}


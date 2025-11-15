import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_session_model.freezed.dart';
part 'exam_session_model.g.dart';

@freezed
class ExamSessionModel with _$ExamSessionModel {
  const factory ExamSessionModel({
    required int id,
    required int examId,
    required String examTitle,
    required int studentId,
    required String studentName,
    required String sessionCode,
    required String status,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    double? totalScore,
    double? percentageScore,
    bool? isPassed,
    int? violationCount,
    int? answeredQuestions,
    int? totalQuestions,
    DateTime? createdAt,
  }) = _ExamSessionModel;

  factory ExamSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSessionModelFromJson(json);
}

@freezed
class ExamInfo with _$ExamInfo {
  const factory ExamInfo({
    required int id,
    required String title,
    required String description,
    required int duration,
    required int totalQuestions,
    required SubjectInfo subject,
  }) = _ExamInfo;

  factory ExamInfo.fromJson(Map<String, dynamic> json) =>
      _$ExamInfoFromJson(json);
}

@freezed
class SubjectInfo with _$SubjectInfo {
  const factory SubjectInfo({
    required int id,
    required String name,
    required String code,
  }) = _SubjectInfo;

  factory SubjectInfo.fromJson(Map<String, dynamic> json) =>
      _$SubjectInfoFromJson(json);
}

@freezed
class TakeExamModel with _$TakeExamModel {
  const factory TakeExamModel({
    required int sessionId,
    required String sessionCode,
    required String examTitle,
    required int durationMinutes,
    required List<QuestionModel> questions,
    required DateTime startTime,
    required DateTime endTime,
    int? remainingTime, // in seconds
  }) = _TakeExamModel;

  factory TakeExamModel.fromJson(Map<String, dynamic> json) {
    // Custom parsing to match backend response structure
    return TakeExamModel(
      sessionId: (json['sessionId'] as num).toInt(),
      sessionCode: json['sessionCode'] as String,
      examTitle: json['examTitle'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      questions: (json['questions'] as List<dynamic>)
          .map((e) => QuestionModelExtension.fromBackendJson(e as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      remainingTime: (json['remainingTime'] as num?)?.toInt(),
    );
  }
}

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required int id,
    required String content,
    required String type,
    @Default(0) int orderNumber,
    double? points,
    PassageInfo? passage,
    required List<AnswerModel> answers,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

extension QuestionModelExtension on QuestionModel {
  /// Custom factory to parse from backend response structure
  /// Backend uses 'questionId' instead of 'id' and 'questionType' instead of 'type'
  static QuestionModel fromBackendJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: (json['questionId'] as num).toInt(),
      content: json['content'] as String,
      type: (json['questionType'] as String).toUpperCase(),
      orderNumber: 0, // Not provided in backend response
      points: json['points'] != null
          ? (json['points'] is num
              ? (json['points'] as num).toDouble()
              : double.tryParse(json['points'].toString()))
          : null,
      passage: null, // Not provided in backend response
      answers: (json['answers'] as List<dynamic>)
          .map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

@freezed
class PassageInfo with _$PassageInfo {
  const factory PassageInfo({
    required int id,
    required String content,
  }) = _PassageInfo;

  factory PassageInfo.fromJson(Map<String, dynamic> json) =>
      _$PassageInfoFromJson(json);
}

@freezed
class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required int id,
    required String content,
    @Default(0) int displayOrder,
    bool? isCorrect, // Only shown after exam completion
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
}

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

  factory ExamResultModel.fromJson(Map<String, dynamic> json) {
    // Custom parsing to match backend response structure
    return ExamResultModel(
      sessionId: (json['sessionId'] as num).toInt(),
      sessionCode: json['sessionCode'] as String,
      examTitle: json['examTitle'] as String,
      studentName: json['studentName'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      totalScore: (json['totalScore'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      percentageScore: (json['percentageScore'] as num).toDouble(),
      isPassed: json['isPassed'] as bool,
      passingScore: (json['passingScore'] as num).toDouble(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      violationCount: (json['violationCount'] as num).toInt(),
      questionResults: json['questionResults'] != null
          ? (json['questionResults'] as List<dynamic>)
              .map((e) => QuestionResultModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
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

  factory QuestionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionResultModel(
      questionId: (json['questionId'] as num).toInt(),
      content: json['content'] as String,
      studentAnswer: json['studentAnswer'] as String?,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: (json['pointsEarned'] as num).toDouble(),
      maxPoints: (json['maxPoints'] as num).toDouble(),
      explanation: json['explanation'] as String?,
    );
  }
}


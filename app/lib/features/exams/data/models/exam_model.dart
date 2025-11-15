import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_model.freezed.dart';
part 'exam_model.g.dart';

@freezed
class ExamModel with _$ExamModel {
  const factory ExamModel({
    required int id,
    required int subjectId,
    required String subjectName,
    required String title,
    String? description,
    required int durationMinutes,
    required int totalQuestions,
    required double totalPoints,
    required double passingScore,
    required String examType,
    required bool isShuffled,
    required bool isShuffleAnswers,
    required bool showResultImmediately,
    required bool allowReview,
    required bool isActive,
    required DateTime createdAt,
    required String createdBy,
  }) = _ExamModel;

  factory ExamModel.fromJson(Map<String, dynamic> json) =>
      _$ExamModelFromJson(json);
}

@freezed
class ExamDetailModel with _$ExamDetailModel {
  const factory ExamDetailModel({
    required int id,
    required int subjectId,
    required String subjectName,
    required String title,
    String? description,
    required int durationMinutes,
    required int totalQuestions,
    required double totalPoints,
    required double passingScore,
    required String examType,
    required bool isShuffled,
    required bool isShuffleAnswers,
    required bool showResultImmediately,
    required bool allowReview,
    required bool isActive,
    required DateTime createdAt,
    required String createdBy,
    required List<ExamQuestionModel> questions,
  }) = _ExamDetailModel;

  factory ExamDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ExamDetailModelFromJson(json);
}

@freezed
class ExamQuestionModel with _$ExamQuestionModel {
  const factory ExamQuestionModel({
    required int id,
    required int questionId,
    required String content,
    required String questionType,
    String? difficultyLevel,
    required int displayOrder,
    required double points,
    String? explanation,
    required List<ExamAnswerModel> answers,
  }) = _ExamQuestionModel;

  factory ExamQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionModelFromJson(json);
}

@freezed
class ExamAnswerModel with _$ExamAnswerModel {
  const factory ExamAnswerModel({
    required int id,
    @_AnyToStringConverter() required String content,
    required int displayOrder,
  }) = _ExamAnswerModel;

  factory ExamAnswerModel.fromJson(Map<String, dynamic> json) =>
      _$ExamAnswerModelFromJson(json);
}

// Create Exam Request
@freezed
class CreateExamRequest with _$CreateExamRequest {
  const factory CreateExamRequest({
    required int subjectId,
    required String title,
    String? description,
    required int durationMinutes,
    required double passingScore,
    @Default('REGULAR') String examType,
    @Default(true) bool isShuffled,
    @Default(true) bool isShuffleAnswers,
    @Default(false) bool showResultImmediately,
    @Default(true) bool allowReview,
  }) = _CreateExamRequest;

  factory CreateExamRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExamRequestFromJson(json);
}

// Add Questions to Exam Request
@freezed
class AddQuestionsRequest with _$AddQuestionsRequest {
  const factory AddQuestionsRequest({
    required List<ExamQuestionItem> questions,
  }) = _AddQuestionsRequest;

  factory AddQuestionsRequest.fromJson(Map<String, dynamic> json) =>
      _$AddQuestionsRequestFromJson(json);
}

@freezed
class ExamQuestionItem with _$ExamQuestionItem {
  const factory ExamQuestionItem({
    required int questionId,
    required int displayOrder,
    required double points,
  }) = _ExamQuestionItem;

  factory ExamQuestionItem.fromJson(Map<String, dynamic> json) =>
      _$ExamQuestionItemFromJson(json);
}

class _AnyToStringConverter implements JsonConverter<String, dynamic> {
  const _AnyToStringConverter();

  @override
  String fromJson(dynamic json) => json?.toString() ?? '';

  @override
  dynamic toJson(String object) => object;
}

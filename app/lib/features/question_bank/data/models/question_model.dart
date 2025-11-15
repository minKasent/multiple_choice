import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../exams/data/models/question_type.dart';

part 'question_model.freezed.dart';
part 'question_model.g.dart';

@freezed
class QuestionModel with _$QuestionModel {
  const factory QuestionModel({
    required int id,
    required int passageId,
    required String content,
    @QuestionTypeConverter() required QuestionType questionType,
    required List<AnswerModel> answers,
    required double points,
    String? explanation,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _QuestionModel;

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);
}

@freezed
class AnswerModel with _$AnswerModel {
  const factory AnswerModel({
    required int id,
    required String content,
    required bool isCorrect,
    int? displayOrder,
  }) = _AnswerModel;

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);
}

@freezed
class CreateQuestionRequest with _$CreateQuestionRequest {
  const factory CreateQuestionRequest({
    int? passageId,
    int? chapterId,
    required String content,
    @QuestionTypeConverter() required QuestionType questionType,
    required List<CreateAnswerRequest> answers,
    required double points,
    String? explanation,
    int? displayOrder,
  }) = _CreateQuestionRequest;

  factory CreateQuestionRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateQuestionRequestFromJson(json);
}

@freezed
class CreateAnswerRequest with _$CreateAnswerRequest {
  const factory CreateAnswerRequest({
    required String content,
    required bool isCorrect,
    int? displayOrder,
  }) = _CreateAnswerRequest;

  factory CreateAnswerRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateAnswerRequestFromJson(json);
}

@freezed
class UpdateQuestionRequest with _$UpdateQuestionRequest {
  const factory UpdateQuestionRequest({
    String? content,
    @QuestionTypeConverter() QuestionType? questionType,
    List<CreateAnswerRequest>? answers,
    double? points,
    String? explanation,
    int? displayOrder,
  }) = _UpdateQuestionRequest;

  factory UpdateQuestionRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateQuestionRequestFromJson(json);
}

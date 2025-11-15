import 'package:freezed_annotation/freezed_annotation.dart';

enum QuestionType {
  @JsonValue('SINGLE_CHOICE')
  singleChoice,
  @JsonValue('MULTIPLE_CHOICE')
  multipleChoice,
  @JsonValue('TRUE_FALSE')
  trueFalse,
  @JsonValue('FILL_IN_BLANK')
  fillInBlank,
}

class QuestionTypeConverter implements JsonConverter<QuestionType, String> {
  const QuestionTypeConverter();

  @override
  QuestionType fromJson(String json) {
    switch (json) {
      case 'SINGLE_CHOICE':
        return QuestionType.singleChoice;
      case 'MULTIPLE_CHOICE':
        return QuestionType.multipleChoice;
      case 'TRUE_FALSE':
        return QuestionType.trueFalse;
      case 'FILL_IN_BLANK':
        return QuestionType.fillInBlank;
      default:
        return QuestionType.singleChoice;
    }
  }

  @override
  String toJson(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'SINGLE_CHOICE';
      case QuestionType.multipleChoice:
        return 'MULTIPLE_CHOICE';
      case QuestionType.trueFalse:
        return 'TRUE_FALSE';
      case QuestionType.fillInBlank:
        return 'FILL_IN_BLANK';
    }
  }
}

extension QuestionTypeExtension on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.singleChoice:
        return 'Trắc nghiệm đơn';
      case QuestionType.multipleChoice:
        return 'Trắc nghiệm đa lựa chọn';
      case QuestionType.trueFalse:
        return 'Đúng/Sai';
      case QuestionType.fillInBlank:
        return 'Điền khuyết';
    }
  }
}


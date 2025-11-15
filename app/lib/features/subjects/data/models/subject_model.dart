import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject_model.freezed.dart';
part 'subject_model.g.dart';

@freezed
class SubjectModel with _$SubjectModel {
  const factory SubjectModel({
    required int id,
    required String code,
    required String name,
    String? description,
    required bool isActive,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _SubjectModel;

  factory SubjectModel.fromJson(Map<String, dynamic> json) =>
      _$SubjectModelFromJson(json);
}

@freezed
class ChapterModel with _$ChapterModel {
  const factory ChapterModel({
    required int id,
    required int subjectId,
    required String title,
    String? description,
    required int orderIndex,
    required DateTime createdAt,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);
}


import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter_model.freezed.dart';
part 'chapter_model.g.dart';

@freezed
class ChapterModel with _$ChapterModel {
  const factory ChapterModel({
    required int id,
    required int subjectId,
    required int chapterNumber,
    required String title,
    String? description,
    required int displayOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ChapterModel;

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);
}

@freezed
class CreateChapterRequest with _$CreateChapterRequest {
  const factory CreateChapterRequest({
    required int subjectId,
    required int chapterNumber,
    required String title,
    String? description,
    required int displayOrder,
  }) = _CreateChapterRequest;

  factory CreateChapterRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateChapterRequestFromJson(json);
}

@freezed
class UpdateChapterRequest with _$UpdateChapterRequest {
  const factory UpdateChapterRequest({
    int? chapterNumber,
    String? title,
    String? description,
    int? displayOrder,
  }) = _UpdateChapterRequest;

  factory UpdateChapterRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateChapterRequestFromJson(json);
}

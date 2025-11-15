import 'package:freezed_annotation/freezed_annotation.dart';

part 'passage_model.freezed.dart';
part 'passage_model.g.dart';

@freezed
class PassageModel with _$PassageModel {
  const factory PassageModel({
    required int id,
    required int chapterId,
    required String title,
    required String content,
    String? imageUrl,
    int? orderIndex,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PassageModel;

  factory PassageModel.fromJson(Map<String, dynamic> json) =>
      _$PassageModelFromJson(json);
}

@freezed
class CreatePassageRequest with _$CreatePassageRequest {
  const factory CreatePassageRequest({
    required int chapterId,
    required String title,
    required String content,
    String? imageUrl,
    int? orderIndex,
  }) = _CreatePassageRequest;

  factory CreatePassageRequest.fromJson(Map<String, dynamic> json) =>
      _$CreatePassageRequestFromJson(json);
}

@freezed
class UpdatePassageRequest with _$UpdatePassageRequest {
  const factory UpdatePassageRequest({
    String? title,
    String? content,
    String? imageUrl,
    int? orderIndex,
  }) = _UpdatePassageRequest;

  factory UpdatePassageRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdatePassageRequestFromJson(json);
}

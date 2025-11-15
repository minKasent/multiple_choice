import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_room_model.freezed.dart';
part 'exam_room_model.g.dart';

@freezed
class ExamRoomModel with _$ExamRoomModel {
  const factory ExamRoomModel({
    required int id,
    required String name,
    required String code,
    String? location,
    int? capacity,
    String? description,
    @Default([]) List<ProctorInfoModel> proctors,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ExamRoomModel;

  factory ExamRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ExamRoomModelFromJson(json);
}

@freezed
class ProctorInfoModel with _$ProctorInfoModel {
  const factory ProctorInfoModel({
    required int id,
    required String fullName,
    required String email,
    required DateTime assignedAt,
  }) = _ProctorInfoModel;

  factory ProctorInfoModel.fromJson(Map<String, dynamic> json) =>
      _$ProctorInfoModelFromJson(json);
}

@freezed
class CreateExamRoomRequest with _$CreateExamRoomRequest {
  const factory CreateExamRoomRequest({
    required String name,
    required String code,
    String? location,
    int? capacity,
    String? description,
  }) = _CreateExamRoomRequest;

  factory CreateExamRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateExamRoomRequestFromJson(json);
}

@freezed
class UpdateExamRoomRequest with _$UpdateExamRoomRequest {
  const factory UpdateExamRoomRequest({
    String? name,
    String? location,
    int? capacity,
    String? description,
  }) = _UpdateExamRoomRequest;

  factory UpdateExamRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateExamRoomRequestFromJson(json);
}

@freezed
class AssignProctorRequest with _$AssignProctorRequest {
  const factory AssignProctorRequest({
    required List<int> proctorIds,
  }) = _AssignProctorRequest;

  factory AssignProctorRequest.fromJson(Map<String, dynamic> json) =>
      _$AssignProctorRequestFromJson(json);
}


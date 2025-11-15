import 'package:freezed_annotation/freezed_annotation.dart';

part 'exam_session_model.freezed.dart';
part 'exam_session_model.g.dart';

@freezed
class ExamSessionModel with _$ExamSessionModel {
  const factory ExamSessionModel({
    required int id,
    required String sessionCode,
    required int examId,
    required String examTitle,
    required int studentId,
    required String studentName,
    required String status,
    required DateTime startTime,
    required DateTime endTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    double? totalScore,
    double? percentageScore,
    bool? isPassed,
    int? violationCount,
    int? examRoomId,
    String? examRoomName,
  }) = _ExamSessionModel;

  factory ExamSessionModel.fromJson(Map<String, dynamic> json) =>
      _$ExamSessionModelFromJson(json);
}

@freezed
class ScheduleExamRequest with _$ScheduleExamRequest {
  const factory ScheduleExamRequest({
    required int examId,
    int? examRoomId,
    required List<int> studentIds,
    required DateTime startTime,
  }) = _ScheduleExamRequest;

  factory ScheduleExamRequest.fromJson(Map<String, dynamic> json) =>
      _$ScheduleExamRequestFromJson(json);
}


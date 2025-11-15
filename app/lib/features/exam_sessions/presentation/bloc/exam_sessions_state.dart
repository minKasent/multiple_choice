import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/exam_session_model.dart';

part 'exam_sessions_state.freezed.dart';

@freezed
class ExamSessionsState with _$ExamSessionsState {
  const factory ExamSessionsState.initial() = _Initial;
  const factory ExamSessionsState.loading() = _Loading;
  const factory ExamSessionsState.sessionsLoaded(
    List<ExamSessionModel> sessions,
  ) = _SessionsLoaded;
  const factory ExamSessionsState.sessionLoaded(ExamSessionModel session) =
      _SessionLoaded;
  const factory ExamSessionsState.scheduled(List<ExamSessionModel> sessions) =
      _Scheduled;
  const factory ExamSessionsState.error(String message) = _Error;
}


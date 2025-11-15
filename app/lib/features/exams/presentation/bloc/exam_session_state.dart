import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/exam_session_model.dart';

part 'exam_session_state.freezed.dart';

@freezed
class ExamSessionState with _$ExamSessionState {
  const factory ExamSessionState.initial() = _Initial;
  const factory ExamSessionState.loading() = _Loading;
  const factory ExamSessionState.examsLoaded(List<ExamSessionModel> exams) = _ExamsLoaded;
  const factory ExamSessionState.examStarted(TakeExamModel exam) = _ExamStarted;
  const factory ExamSessionState.answerSubmitted() = _AnswerSubmitted;
  const factory ExamSessionState.examCompleted(ExamResultModel result) = _ExamCompleted;
  const factory ExamSessionState.error(String message) = _Error;
}


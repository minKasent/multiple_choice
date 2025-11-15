import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/exam_model.dart';

part 'exams_state.freezed.dart';

@freezed
class ExamsState with _$ExamsState {
  const factory ExamsState.initial() = _Initial;
  const factory ExamsState.loading() = _Loading;
  const factory ExamsState.examsLoaded(List<ExamModel> exams) = _ExamsLoaded;
  const factory ExamsState.examDetailLoaded(ExamDetailModel exam) =
      _ExamDetailLoaded;
  const factory ExamsState.examCreated(ExamModel exam) = _ExamCreated;
  const factory ExamsState.examUpdated(ExamModel exam) = _ExamUpdated;
  const factory ExamsState.examDeleted() = _ExamDeleted;
  const factory ExamsState.questionsAdded(ExamDetailModel exam) =
      _QuestionsAdded;
  const factory ExamsState.questionRemoved() = _QuestionRemoved;
  const factory ExamsState.examShuffled(ExamDetailModel exam) = _ExamShuffled;
  const factory ExamsState.examCloned(ExamModel exam) = _ExamCloned;
  const factory ExamsState.error(String message) = _Error;
}

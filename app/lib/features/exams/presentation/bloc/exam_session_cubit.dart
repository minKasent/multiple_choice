import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/exam_session_repository.dart';
import 'exam_session_state.dart';

@injectable
class ExamSessionCubit extends Cubit<ExamSessionState> {
  final ExamSessionRepository _repository;

  ExamSessionCubit(this._repository) : super(const ExamSessionState.initial());

  Future<void> loadMyExams() async {
    emit(const ExamSessionState.loading());

    final result = await _repository.getMyExams();

    result.fold(
      (failure) => emit(ExamSessionState.error(failure.message)),
      (exams) => emit(ExamSessionState.examsLoaded(exams)),
    );
  }

  Future<void> startExam(int sessionId) async {
    emit(const ExamSessionState.loading());

    final result = await _repository.startExam(sessionId);

    result.fold(
      (failure) => emit(ExamSessionState.error(failure.message)),
      (exam) => emit(ExamSessionState.examStarted(exam)),
    );
  }

  Future<void> submitAnswer(
    int sessionId,
    int questionId,
    List<int> answerIds,
  ) async {
    final result = await _repository.submitAnswer(
      sessionId,
      questionId,
      answerIds,
    );

    result.fold(
      (failure) => emit(ExamSessionState.error(failure.message)),
      (_) => emit(const ExamSessionState.answerSubmitted()),
    );
  }

  Future<void> completeExam(int sessionId) async {
    emit(const ExamSessionState.loading());

    final result = await _repository.completeExam(sessionId);

    result.fold(
      (failure) => emit(ExamSessionState.error(failure.message)),
      (examResult) => emit(ExamSessionState.examCompleted(examResult)),
    );
  }

  Future<void> getExamResult(int sessionId) async {
    emit(const ExamSessionState.loading());

    final result = await _repository.getExamResult(sessionId);

    result.fold(
      (failure) => emit(ExamSessionState.error(failure.message)),
      (examResult) => emit(ExamSessionState.examCompleted(examResult)),
    );
  }
}


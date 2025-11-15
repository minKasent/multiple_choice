import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/exam_model.dart';
import '../../domain/repositories/exams_repository.dart';
import 'exams_state.dart';

@injectable
class ExamsCubit extends Cubit<ExamsState> {
  final ExamsRepository _repository;

  ExamsCubit(this._repository) : super(const ExamsState.initial());

  Future<void> loadAllExams({int page = 0, int size = 20}) async {
    emit(const ExamsState.loading());

    final result = await _repository.getAllExams(page: page, size: size);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exams) => emit(ExamsState.examsLoaded(exams)),
    );
  }

  Future<void> loadExamsBySubject(
    int subjectId, {
    int page = 0,
    int size = 20,
  }) async {
    emit(const ExamsState.loading());

    final result = await _repository.getExamsBySubject(
      subjectId,
      page: page,
      size: size,
    );

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exams) => emit(ExamsState.examsLoaded(exams)),
    );
  }

  Future<void> searchExams(
    String keyword, {
    int page = 0,
    int size = 20,
  }) async {
    emit(const ExamsState.loading());

    final result = await _repository.searchExams(
      keyword,
      page: page,
      size: size,
    );

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exams) => emit(ExamsState.examsLoaded(exams)),
    );
  }

  Future<void> loadExamDetail(int examId) async {
    emit(const ExamsState.loading());

    final result = await _repository.getExamDetail(examId);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.examDetailLoaded(exam)),
    );
  }

  Future<void> createExam(CreateExamRequest request) async {
    emit(const ExamsState.loading());

    final result = await _repository.createExam(request);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.examCreated(exam)),
    );
  }

  Future<void> updateExam(int examId, CreateExamRequest request) async {
    emit(const ExamsState.loading());

    final result = await _repository.updateExam(examId, request);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.examUpdated(exam)),
    );
  }

  Future<void> deleteExam(int examId) async {
    emit(const ExamsState.loading());

    final result = await _repository.deleteExam(examId);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (_) => emit(const ExamsState.examDeleted()),
    );
  }

  Future<void> addQuestionsToExam(
    int examId,
    AddQuestionsRequest request,
  ) async {
    emit(const ExamsState.loading());

    final result = await _repository.addQuestionsToExam(examId, request);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.questionsAdded(exam)),
    );
  }

  Future<void> removeQuestionFromExam(int examId, int questionId) async {
    emit(const ExamsState.loading());

    final result = await _repository.removeQuestionFromExam(examId, questionId);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (_) => emit(const ExamsState.questionRemoved()),
    );
  }

  Future<void> shuffleExam(int examId) async {
    emit(const ExamsState.loading());

    final result = await _repository.shuffleExam(examId);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.examShuffled(exam)),
    );
  }

  Future<void> cloneExam(int examId) async {
    emit(const ExamsState.loading());

    final result = await _repository.cloneExam(examId);

    result.fold(
      (failure) => emit(ExamsState.error(failure.message)),
      (exam) => emit(ExamsState.examCloned(exam)),
    );
  }
}

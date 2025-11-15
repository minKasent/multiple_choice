import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/question_bank_repository.dart';
import 'question_bank_state.dart';

@injectable
class QuestionBankCubit extends Cubit<QuestionBankState> {
  final QuestionBankRepository _repository;

  QuestionBankCubit(this._repository) : super(const QuestionBankState.initial());

  // ============ CHAPTERS ============
  
  Future<void> loadChaptersBySubject(int subjectId) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.getChaptersBySubject(subjectId);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (chapters) => emit(QuestionBankState.chaptersLoaded(chapters)),
    );
  }

  Future<void> createChapter(int subjectId, Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.createChapter(subjectId, data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (chapter) => emit(QuestionBankState.chapterCreated(chapter)),
    );
  }

  Future<void> updateChapter(int id, Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.updateChapter(id, data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (chapter) => emit(QuestionBankState.chapterUpdated(chapter)),
    );
  }

  Future<void> deleteChapter(int id) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.deleteChapter(id);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (_) => emit(const QuestionBankState.chapterDeleted()),
    );
  }

  // ============ PASSAGES ============
  
  Future<void> loadPassagesByChapter(int chapterId) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.getPassagesByChapter(chapterId);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (passages) => emit(QuestionBankState.passagesLoaded(passages)),
    );
  }

  Future<void> createPassage(int chapterId, Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.createPassage(chapterId, data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (passage) => emit(QuestionBankState.passageCreated(passage)),
    );
  }

  Future<void> updatePassage(int id, Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.updatePassage(id, data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (passage) => emit(QuestionBankState.passageUpdated(passage)),
    );
  }

  Future<void> deletePassage(int id) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.deletePassage(id);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (_) => emit(const QuestionBankState.passageDeleted()),
    );
  }

  // ============ QUESTIONS ============
  
  Future<void> loadQuestionsByPassage(int passageId) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.getQuestionsByPassage(passageId);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (questions) => emit(QuestionBankState.questionsLoaded(questions)),
    );
  }

  Future<void> loadQuestionsByChapter(int chapterId) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.getQuestionsByChapter(chapterId);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (questions) => emit(QuestionBankState.questionsLoaded(questions)),
    );
  }

  Future<void> createQuestion(Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.createQuestion(data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (question) => emit(QuestionBankState.questionCreated(question)),
    );
  }

  Future<void> updateQuestion(int id, Map<String, dynamic> data) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.updateQuestion(id, data);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (question) => emit(QuestionBankState.questionUpdated(question)),
    );
  }

  Future<void> deleteQuestion(int id) async {
    emit(const QuestionBankState.loading());

    final result = await _repository.deleteQuestion(id);

    result.fold(
      (failure) => emit(QuestionBankState.error(failure.message)),
      (_) => emit(const QuestionBankState.questionDeleted()),
    );
  }
}

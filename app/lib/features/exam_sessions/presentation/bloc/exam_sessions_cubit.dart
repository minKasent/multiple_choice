import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/exam_session_model.dart';
import '../../domain/repositories/exam_sessions_repository.dart';
import 'exam_sessions_state.dart';

@injectable
class ExamSessionsCubit extends Cubit<ExamSessionsState> {
  final ExamSessionsRepository _repository;

  ExamSessionsCubit(this._repository)
      : super(const ExamSessionsState.initial());

  Future<void> scheduleExam(ScheduleExamRequest request) async {
    emit(const ExamSessionsState.loading());

    final result = await _repository.scheduleExam(request);

    result.fold(
      (failure) => emit(ExamSessionsState.error(failure.message)),
      (sessions) => emit(ExamSessionsState.scheduled(sessions)),
    );
  }

  Future<void> loadMyExams({int page = 0, int size = 20}) async {
    emit(const ExamSessionsState.loading());

    final result = await _repository.getMyExams(page: page, size: size);

    result.fold(
      (failure) => emit(ExamSessionsState.error(failure.message)),
      (sessions) => emit(ExamSessionsState.sessionsLoaded(sessions)),
    );
  }

  Future<void> loadExamSession(int id) async {
    emit(const ExamSessionsState.loading());

    final result = await _repository.getExamSession(id);

    result.fold(
      (failure) => emit(ExamSessionsState.error(failure.message)),
      (session) => emit(ExamSessionsState.sessionLoaded(session)),
    );
  }
}


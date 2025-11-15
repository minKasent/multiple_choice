import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/statistics_repository.dart';
import 'statistics_state.dart';

@injectable
class StatisticsCubit extends Cubit<StatisticsState> {
  final StatisticsRepository _repository;

  StatisticsCubit(this._repository) : super(const StatisticsState.initial());

  Future<void> loadStudentStatistics(int studentId) async {
    emit(const StatisticsState.loading());

    final result = await _repository.getStudentStatistics(studentId);

    result.fold(
      (failure) => emit(StatisticsState.error(failure.message)),
      (stats) => emit(StatisticsState.studentStatsLoaded(stats)),
    );
  }

  Future<void> loadMyStatistics() async {
    emit(const StatisticsState.loading());

    final result = await _repository.getMyStatistics();

    result.fold(
      (failure) => emit(StatisticsState.error(failure.message)),
      (stats) => emit(StatisticsState.studentStatsLoaded(stats)),
    );
  }

  Future<void> loadExamStatistics(int examId) async {
    emit(const StatisticsState.loading());

    final result = await _repository.getExamStatistics(examId);

    result.fold(
      (failure) => emit(StatisticsState.error(failure.message)),
      (stats) => emit(StatisticsState.examStatsLoaded(stats)),
    );
  }

  Future<void> loadSubjectStatistics(int subjectId) async {
    emit(const StatisticsState.loading());

    final result = await _repository.getSubjectStatistics(subjectId);

    result.fold(
      (failure) => emit(StatisticsState.error(failure.message)),
      (stats) => emit(StatisticsState.subjectStatsLoaded(stats)),
    );
  }

  Future<void> loadDashboardStatistics() async {
    emit(const StatisticsState.loading());

    final result = await _repository.getDashboardStatistics();

    result.fold(
      (failure) => emit(StatisticsState.error(failure.message)),
      (stats) => emit(StatisticsState.dashboardStatsLoaded(stats)),
    );
  }
}

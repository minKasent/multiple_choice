import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/statistics_model.dart';

part 'statistics_state.freezed.dart';

@freezed
class StatisticsState with _$StatisticsState {
  const factory StatisticsState.initial() = _Initial;
  const factory StatisticsState.loading() = _Loading;
  const factory StatisticsState.studentStatsLoaded(StudentStatsModel stats) =
      _StudentStatsLoaded;
  const factory StatisticsState.examStatsLoaded(ExamStatsModel stats) =
      _ExamStatsLoaded;
  const factory StatisticsState.subjectStatsLoaded(SubjectStatsModel stats) =
      _SubjectStatsLoaded;
  const factory StatisticsState.dashboardStatsLoaded(
    DashboardStatsModel stats,
  ) = _DashboardStatsLoaded;
  const factory StatisticsState.error(String message) = _Error;
}

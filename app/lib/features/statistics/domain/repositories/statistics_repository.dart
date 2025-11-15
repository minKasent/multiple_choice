import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/statistics_model.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, StudentStatsModel>> getStudentStatistics(
    int studentId,
  );
  Future<Either<Failure, StudentStatsModel>> getMyStatistics();
  Future<Either<Failure, ExamStatsModel>> getExamStatistics(int examId);
  Future<Either<Failure, SubjectStatsModel>> getSubjectStatistics(
    int subjectId,
  );
  Future<Either<Failure, DashboardStatsModel>> getDashboardStatistics();
}

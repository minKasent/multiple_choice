import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';
import '../models/statistics_model.dart';

@LazySingleton(as: StatisticsRepository)
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;

  StatisticsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, StudentStatsModel>> getStudentStatistics(
    int studentId,
  ) async {
    try {
      final stats = await remoteDataSource.getStudentStatistics(studentId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, StudentStatsModel>> getMyStatistics() async {
    try {
      final stats = await remoteDataSource.getMyStatistics();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamStatsModel>> getExamStatistics(
    int examId,
  ) async {
    try {
      final stats = await remoteDataSource.getExamStatistics(examId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SubjectStatsModel>> getSubjectStatistics(
    int subjectId,
  ) async {
    try {
      final stats = await remoteDataSource.getSubjectStatistics(subjectId);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, DashboardStatsModel>> getDashboardStatistics() async {
    try {
      final stats = await remoteDataSource.getDashboardStatistics();
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}

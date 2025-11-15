import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/exam_sessions_repository.dart';
import '../datasources/exam_sessions_remote_datasource.dart';
import '../models/exam_session_model.dart';

@LazySingleton(as: ExamSessionsRepository)
class ExamSessionsRepositoryImpl implements ExamSessionsRepository {
  final ExamSessionsRemoteDataSource remoteDataSource;

  ExamSessionsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ExamSessionModel>>> scheduleExam(
    ScheduleExamRequest request,
  ) async {
    try {
      final sessions = await remoteDataSource.scheduleExam(request);
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExamSessionModel>>> getMyExams({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final sessions = await remoteDataSource.getMyExams(
        page: page,
        size: size,
      );
      return Right(sessions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamSessionModel>> getExamSession(int id) async {
    try {
      final session = await remoteDataSource.getExamSession(id);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}

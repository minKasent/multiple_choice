import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/exam_session_repository.dart';
import '../datasources/exam_session_remote_datasource.dart';
import '../models/exam_session_model.dart';

@LazySingleton(as: ExamSessionRepository)
class ExamSessionRepositoryImpl implements ExamSessionRepository {
  final ExamSessionRemoteDataSource _remoteDataSource;

  ExamSessionRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<ExamSessionModel>>> getMyExams() async {
    try {
      final exams = await _remoteDataSource.getMyExams();
      return Right(exams);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load exams'));
    }
  }

  @override
  Future<Either<Failure, ExamSessionModel>> getExamSession(int sessionId) async {
    try {
      final session = await _remoteDataSource.getExamSession(sessionId);
      return Right(session);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load exam session'));
    }
  }

  @override
  Future<Either<Failure, TakeExamModel>> startExam(int sessionId) async {
    try {
      final exam = await _remoteDataSource.startExam(sessionId);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to start exam'));
    }
  }

  @override
  Future<Either<Failure, void>> submitAnswer(
    int sessionId,
    int questionId,
    List<int> answerIds,
  ) async {
    try {
      await _remoteDataSource.submitAnswer(sessionId, questionId, answerIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to submit answer'));
    }
  }

  @override
  Future<Either<Failure, ExamResultModel>> completeExam(int sessionId) async {
    try {
      final result = await _remoteDataSource.completeExam(sessionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to complete exam'));
    }
  }

  @override
  Future<Either<Failure, ExamResultModel>> getExamResult(int sessionId) async {
    try {
      final result = await _remoteDataSource.getExamResult(sessionId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load exam result'));
    }
  }
}


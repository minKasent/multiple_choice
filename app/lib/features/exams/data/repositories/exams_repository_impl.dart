import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/exams_repository.dart';
import '../datasources/exams_remote_datasource.dart';
import '../models/exam_model.dart';

@LazySingleton(as: ExamsRepository)
class ExamsRepositoryImpl implements ExamsRepository {
  final ExamsRemoteDataSource remoteDataSource;

  ExamsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ExamModel>>> getAllExams({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final exams = await remoteDataSource.getAllExams(
        page: page,
        size: size,
      );
      return Right(exams);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExamModel>>> getExamsBySubject(
    int subjectId, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final exams = await remoteDataSource.getExamsBySubject(
        subjectId,
        page: page,
        size: size,
      );
      return Right(exams);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ExamModel>>> searchExams(
    String keyword, {
    int page = 0,
    int size = 20,
  }) async {
    try {
      final exams = await remoteDataSource.searchExams(
        keyword,
        page: page,
        size: size,
      );
      return Right(exams);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamModel>> getExamById(int id) async {
    try {
      final exam = await remoteDataSource.getExamById(id);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamDetailModel>> getExamDetail(int id) async {
    try {
      final exam = await remoteDataSource.getExamDetail(id);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamModel>> createExam(
    CreateExamRequest request,
  ) async {
    try {
      final exam = await remoteDataSource.createExam(request);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamModel>> updateExam(
    int id,
    CreateExamRequest request,
  ) async {
    try {
      final exam = await remoteDataSource.updateExam(id, request);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExam(int id) async {
    try {
      await remoteDataSource.deleteExam(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamDetailModel>> addQuestionsToExam(
    int examId,
    AddQuestionsRequest request,
  ) async {
    try {
      final exam = await remoteDataSource.addQuestionsToExam(examId, request);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeQuestionFromExam(
    int examId,
    int questionId,
  ) async {
    try {
      await remoteDataSource.removeQuestionFromExam(examId, questionId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamDetailModel>> shuffleExam(int examId) async {
    try {
      final exam = await remoteDataSource.shuffleExam(examId);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, ExamModel>> cloneExam(int examId) async {
    try {
      final exam = await remoteDataSource.cloneExam(examId);
      return Right(exam);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}

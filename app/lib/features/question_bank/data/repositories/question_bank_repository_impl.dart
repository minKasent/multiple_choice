import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/question_bank_repository.dart';
import '../datasources/question_bank_remote_datasource.dart';
import '../models/chapter_model.dart';
import '../models/passage_model.dart';
import '../models/question_model.dart';

@LazySingleton(as: QuestionBankRepository)
class QuestionBankRepositoryImpl implements QuestionBankRepository {
  final QuestionBankRemoteDataSource _remoteDataSource;

  QuestionBankRepositoryImpl(this._remoteDataSource);

  // Chapters
  @override
  Future<Either<Failure, List<ChapterModel>>> getChaptersBySubject(
      int subjectId) async {
    try {
      final chapters = await _remoteDataSource.getChaptersBySubject(subjectId);
      return Right(chapters);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load chapters'));
    }
  }

  @override
  Future<Either<Failure, ChapterModel>> getChapterById(int id) async {
    try {
      final chapter = await _remoteDataSource.getChapterById(id);
      return Right(chapter);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load chapter'));
    }
  }

  @override
  Future<Either<Failure, ChapterModel>> createChapter(
      int subjectId, Map<String, dynamic> data) async {
    try {
      final chapter = await _remoteDataSource.createChapter(subjectId, data);
      return Right(chapter);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create chapter'));
    }
  }

  @override
  Future<Either<Failure, ChapterModel>> updateChapter(
      int id, Map<String, dynamic> data) async {
    try {
      final chapter = await _remoteDataSource.updateChapter(id, data);
      return Right(chapter);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update chapter'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChapter(int id) async {
    try {
      await _remoteDataSource.deleteChapter(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete chapter'));
    }
  }

  // Passages
  @override
  Future<Either<Failure, List<PassageModel>>> getPassagesByChapter(
      int chapterId) async {
    try {
      final passages = await _remoteDataSource.getPassagesByChapter(chapterId);
      return Right(passages);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load passages'));
    }
  }

  @override
  Future<Either<Failure, PassageModel>> getPassageById(int id) async {
    try {
      final passage = await _remoteDataSource.getPassageById(id);
      return Right(passage);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load passage'));
    }
  }

  @override
  Future<Either<Failure, PassageModel>> createPassage(
      int chapterId, Map<String, dynamic> data) async {
    try {
      final passage = await _remoteDataSource.createPassage(chapterId, data);
      return Right(passage);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create passage'));
    }
  }

  @override
  Future<Either<Failure, PassageModel>> updatePassage(
      int id, Map<String, dynamic> data) async {
    try {
      final passage = await _remoteDataSource.updatePassage(id, data);
      return Right(passage);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update passage'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePassage(int id) async {
    try {
      await _remoteDataSource.deletePassage(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete passage'));
    }
  }

  // Questions
  @override
  Future<Either<Failure, List<QuestionModel>>> getQuestionsByPassage(
      int passageId) async {
    try {
      final questions =
          await _remoteDataSource.getQuestionsByPassage(passageId);
      return Right(questions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load questions'));
    }
  }

  @override
  Future<Either<Failure, List<QuestionModel>>> getQuestionsByChapter(
      int chapterId) async {
    try {
      final questions =
          await _remoteDataSource.getQuestionsByChapter(chapterId);
      return Right(questions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load questions'));
    }
  }

  @override
  Future<Either<Failure, QuestionModel>> getQuestionById(int id) async {
    try {
      final question = await _remoteDataSource.getQuestionById(id);
      return Right(question);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to load question'));
    }
  }

  @override
  Future<Either<Failure, QuestionModel>> createQuestion(
      Map<String, dynamic> data) async {
    try {
      final question = await _remoteDataSource.createQuestion(data);
      return Right(question);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create question'));
    }
  }

  @override
  Future<Either<Failure, QuestionModel>> updateQuestion(
      int id, Map<String, dynamic> data) async {
    try {
      final question = await _remoteDataSource.updateQuestion(id, data);
      return Right(question);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update question'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuestion(int id) async {
    try {
      await _remoteDataSource.deleteQuestion(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to delete question'));
    }
  }
}

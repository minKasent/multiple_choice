import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/chapter_model.dart';
import '../../data/models/passage_model.dart';
import '../../data/models/question_model.dart';

abstract class QuestionBankRepository {
  // Chapters
  Future<Either<Failure, List<ChapterModel>>> getChaptersBySubject(int subjectId);
  Future<Either<Failure, ChapterModel>> getChapterById(int id);
  Future<Either<Failure, ChapterModel>> createChapter(int subjectId, Map<String, dynamic> data);
  Future<Either<Failure, ChapterModel>> updateChapter(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteChapter(int id);

  // Passages
  Future<Either<Failure, List<PassageModel>>> getPassagesByChapter(int chapterId);
  Future<Either<Failure, PassageModel>> getPassageById(int id);
  Future<Either<Failure, PassageModel>> createPassage(int chapterId, Map<String, dynamic> data);
  Future<Either<Failure, PassageModel>> updatePassage(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deletePassage(int id);

  // Questions
  Future<Either<Failure, List<QuestionModel>>> getQuestionsByPassage(int passageId);
  Future<Either<Failure, List<QuestionModel>>> getQuestionsByChapter(int chapterId);
  Future<Either<Failure, QuestionModel>> getQuestionById(int id);
  Future<Either<Failure, QuestionModel>> createQuestion(Map<String, dynamic> data);
  Future<Either<Failure, QuestionModel>> updateQuestion(int id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteQuestion(int id);
}

